package trader

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// DeltaTrader Delta Exchange trader implementation
// Delta Exchange is a crypto derivatives exchange supporting futures, options, and perpetuals
type DeltaTrader struct {
	apiKey    string
	apiSecret string
	baseURL   string
	client    *http.Client
}

// NewDeltaTrader creates new Delta Exchange trader
func NewDeltaTrader(apiKey, apiSecret string, testnet bool) *DeltaTrader {
	baseURL := "https://api.delta.exchange"
	if testnet {
		baseURL = "https://testnet-api.delta.exchange"
	}

	return &DeltaTrader{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		baseURL:   baseURL,
		client:    &http.Client{Timeout: 30 * time.Second},
	}
}

// generateSignature generates Delta Exchange API signature
// Delta uses HMAC-SHA256 with specific message format: method + path + body + timestamp
func (dt *DeltaTrader) generateSignature(method, path, body string, timestamp int64) string {
	message := fmt.Sprintf("%s%s%s%d", method, path, body, timestamp)
	h := hmac.New(sha256.New, []byte(dt.apiSecret))
	h.Write([]byte(message))
	return hex.EncodeToString(h.Sum(nil))
}

// makeRequest sends HTTP request to Delta Exchange API
func (dt *DeltaTrader) makeRequest(method, endpoint string, params map[string]interface{}) ([]byte, error) {
	var body []byte
	var err error
	
	if params != nil {
		body, err = json.Marshal(params)
		if err != nil {
			return nil, fmt.Errorf("marshal params failed: %w", err)
		}
	}

	url := dt.baseURL + endpoint
	req, err := http.NewRequest(method, url, bytes.NewBuffer(body))
	if err != nil {
		return nil, fmt.Errorf("create request failed: %w", err)
	}

	timestamp := time.Now().Unix()
	signature := dt.generateSignature(method, endpoint, string(body), timestamp)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("api-key", dt.apiKey)
	req.Header.Set("signature", signature)
	req.Header.Set("timestamp", strconv.FormatInt(timestamp, 10))

	resp, err := dt.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response failed: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error (status %d): %s", resp.StatusCode, string(respBody))
	}

	return respBody, nil
}

// GetBalance gets account balance
func (dt *DeltaTrader) GetBalance() (map[string]interface{}, error) {
	respBody, err := dt.makeRequest("GET", "/v2/wallet/balances", nil)
	if err != nil {
		return nil, err
	}

	var response struct {
		Success bool `json:"success"`
		Result  []struct {
			Asset     string  `json:"asset"`
			Balance   float64 `json:"balance,string"`
			Available float64 `json:"available_balance,string"`
		} `json:"result"`
	}

	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	if !response.Success {
		return nil, fmt.Errorf("API returned error")
	}

	// Find USDT balance
	for _, balance := range response.Result {
		if balance.Asset == "USDT" {
			return map[string]interface{}{
				"totalWalletBalance": balance.Balance,
				"availableBalance":   balance.Available,
				"totalMarginBalance": balance.Balance,
			}, nil
		}
	}

	return map[string]interface{}{
		"totalWalletBalance": 0.0,
		"availableBalance":   0.0,
		"totalMarginBalance": 0.0,
	}, nil
}

// GetPositions gets all positions
func (dt *DeltaTrader) GetPositions() ([]map[string]interface{}, error) {
	respBody, err := dt.makeRequest("GET", "/v2/positions", nil)
	if err != nil {
		return nil, err
	}

	var response struct {
		Success bool `json:"success"`
		Result  []struct {
			Symbol       string  `json:"symbol"`
			Size         float64 `json:"size,string"`
			EntryPrice   float64 `json:"entry_price,string"`
			MarkPrice    float64 `json:"mark_price,string"`
			PnL          float64 `json:"unrealized_pnl,string"`
			PnLPercent   float64 `json:"unrealized_pnl_percent,string"`
			Side         string  `json:"side"`
			Leverage     int     `json:"leverage"`
		} `json:"result"`
	}

	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	if !response.Success {
		return nil, fmt.Errorf("API returned error")
	}

	var positions []map[string]interface{}
	for _, pos := range response.Result {
		if pos.Size != 0 {
			positions = append(positions, map[string]interface{}{
				"symbol":                 pos.Symbol,
				"positionAmt":           pos.Size,
				"entryPrice":            pos.EntryPrice,
				"markPrice":             pos.MarkPrice,
				"unRealizedProfit":      pos.PnL,
				"percentage":            pos.PnLPercent,
				"positionSide":          strings.ToUpper(pos.Side),
				"leverage":              pos.Leverage,
			})
		}
	}

	return positions, nil
}

// getProductId gets product ID for symbol
func (dt *DeltaTrader) getProductId(symbol string) (int, error) {
	respBody, err := dt.makeRequest("GET", "/v2/products", nil)
	if err != nil {
		return 0, err
	}

	var response struct {
		Success bool `json:"success"`
		Result  []struct {
			ID     int    `json:"id"`
			Symbol string `json:"symbol"`
		} `json:"result"`
	}

	if err := json.Unmarshal(respBody, &response); err != nil {
		return 0, fmt.Errorf("unmarshal response failed: %w", err)
	}

	for _, product := range response.Result {
		if product.Symbol == symbol {
			return product.ID, nil
		}
	}

	return 0, fmt.Errorf("product not found: %s", symbol)
}

// OpenLong opens long position
func (dt *DeltaTrader) OpenLong(symbol string, quantity float64, leverage int) (map[string]interface{}, error) {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return nil, err
	}

	params := map[string]interface{}{
		"product_id": productId,
		"size":       quantity,
		"side":       "buy",
		"order_type": "market_order",
		"leverage":   leverage,
	}

	respBody, err := dt.makeRequest("POST", "/v2/orders", params)
	if err != nil {
		return nil, err
	}

	var response map[string]interface{}
	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	return response, nil
}

// OpenShort opens short position
func (dt *DeltaTrader) OpenShort(symbol string, quantity float64, leverage int) (map[string]interface{}, error) {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return nil, err
	}

	params := map[string]interface{}{
		"product_id": productId,
		"size":       quantity,
		"side":       "sell",
		"order_type": "market_order",
		"leverage":   leverage,
	}

	respBody, err := dt.makeRequest("POST", "/v2/orders", params)
	if err != nil {
		return nil, err
	}

	var response map[string]interface{}
	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	return response, nil
}

// CloseLong closes long position
func (dt *DeltaTrader) CloseLong(symbol string, quantity float64) (map[string]interface{}, error) {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return nil, err
	}

	params := map[string]interface{}{
		"product_id":    productId,
		"size":          quantity,
		"side":          "sell",
		"order_type":    "market_order",
		"reduce_only":   true,
	}

	respBody, err := dt.makeRequest("POST", "/v2/orders", params)
	if err != nil {
		return nil, err
	}

	var response map[string]interface{}
	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	return response, nil
}

// CloseShort closes short position
func (dt *DeltaTrader) CloseShort(symbol string, quantity float64) (map[string]interface{}, error) {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return nil, err
	}

	params := map[string]interface{}{
		"product_id":    productId,
		"size":          quantity,
		"side":          "buy",
		"order_type":    "market_order",
		"reduce_only":   true,
	}

	respBody, err := dt.makeRequest("POST", "/v2/orders", params)
	if err != nil {
		return nil, err
	}

	var response map[string]interface{}
	if err := json.Unmarshal(respBody, &response); err != nil {
		return nil, fmt.Errorf("unmarshal response failed: %w", err)
	}

	return response, nil
}

// SetLeverage sets leverage for symbol
func (dt *DeltaTrader) SetLeverage(symbol string, leverage int) error {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return err
	}

	params := map[string]interface{}{
		"product_id": productId,
		"leverage":   leverage,
	}

	_, err = dt.makeRequest("POST", "/v2/positions/change_margin", params)
	return err
}

// GetMarketPrice gets current market price
func (dt *DeltaTrader) GetMarketPrice(symbol string) (float64, error) {
	endpoint := fmt.Sprintf("/v2/tickers/%s", symbol)
	respBody, err := dt.makeRequest("GET", endpoint, nil)
	if err != nil {
		return 0, err
	}

	var response struct {
		Success bool `json:"success"`
		Result  struct {
			Price float64 `json:"close,string"`
		} `json:"result"`
	}

	if err := json.Unmarshal(respBody, &response); err != nil {
		return 0, fmt.Errorf("unmarshal response failed: %w", err)
	}

	if !response.Success {
		return 0, fmt.Errorf("API returned error")
	}

	return response.Result.Price, nil
}

// SetStopLoss sets stop loss order
func (dt *DeltaTrader) SetStopLoss(symbol string, positionSide string, quantity, stopPrice float64) error {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return err
	}

	side := "sell"
	if positionSide == "SHORT" {
		side = "buy"
	}

	params := map[string]interface{}{
		"product_id":   productId,
		"size":         quantity,
		"side":         side,
		"order_type":   "stop_loss_order",
		"stop_price":   stopPrice,
		"reduce_only":  true,
	}

	_, err = dt.makeRequest("POST", "/v2/orders", params)
	return err
}

// SetTakeProfit sets take profit order
func (dt *DeltaTrader) SetTakeProfit(symbol string, positionSide string, quantity, takeProfitPrice float64) error {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return err
	}

	side := "sell"
	if positionSide == "SHORT" {
		side = "buy"
	}

	params := map[string]interface{}{
		"product_id":   productId,
		"size":         quantity,
		"side":         side,
		"order_type":   "take_profit_order",
		"limit_price":  takeProfitPrice,
		"reduce_only":  true,
	}

	_, err = dt.makeRequest("POST", "/v2/orders", params)
	return err
}

// CancelAllOrders cancels all orders for symbol
func (dt *DeltaTrader) CancelAllOrders(symbol string) error {
	productId, err := dt.getProductId(symbol)
	if err != nil {
		return err
	}

	params := map[string]interface{}{
		"product_id": productId,
	}

	_, err = dt.makeRequest("DELETE", "/v2/orders/all", params)
	return err
}

// FormatQuantity formats quantity to correct precision
func (dt *DeltaTrader) FormatQuantity(symbol string, quantity float64) (string, error) {
	// Delta Exchange typically uses 8 decimal places for precision
	return fmt.Sprintf("%.8f", quantity), nil
}

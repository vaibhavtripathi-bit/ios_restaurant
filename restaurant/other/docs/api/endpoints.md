# API Endpoints Documentation

## Overview

This document describes the API contracts for the Restaurant App. Currently using mock data, but designed for easy integration with a real backend.

## Base URL

```
Production: https://api.restaurant.com/v1
Development: Mock data (local)
```

## Endpoints

### Menu

#### Get All Categories
```
GET /categories

Response:
{
  "categories": [
    {
      "id": "cat-001",
      "name": "Appetizers",
      "imageUrl": "https://...",
      "itemCount": 12
    }
  ]
}
```

#### Get Menu Items by Category
```
GET /categories/{categoryId}/items

Response:
{
  "items": [
    {
      "id": "item-001",
      "name": "Bruschetta",
      "description": "Grilled bread with tomatoes...",
      "price": 8.99,
      "imageUrl": "https://...",
      "categoryId": "cat-001",
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 0,
      "calories": 250,
      "preparationTime": 10
    }
  ]
}
```

#### Get Menu Item Details
```
GET /items/{itemId}

Response:
{
  "item": {
    "id": "item-001",
    "name": "Bruschetta",
    "description": "Grilled bread with tomatoes...",
    "price": 8.99,
    "imageUrl": "https://...",
    "ingredients": ["bread", "tomatoes", "basil", "olive oil"],
    "allergens": ["gluten"],
    "nutritionInfo": {
      "calories": 250,
      "protein": 5,
      "carbs": 30,
      "fat": 12
    }
  }
}
```

### Cart

#### Get Cart
```
GET /cart

Response:
{
  "items": [...],
  "subtotal": 45.97,
  "tax": 4.14,
  "total": 50.11
}
```

#### Add to Cart
```
POST /cart/items

Request:
{
  "itemId": "item-001",
  "quantity": 2,
  "specialInstructions": "No onions"
}
```

#### Update Cart Item
```
PUT /cart/items/{cartItemId}

Request:
{
  "quantity": 3
}
```

#### Remove from Cart
```
DELETE /cart/items/{cartItemId}
```

### Orders

#### Place Order
```
POST /orders

Request:
{
  "items": [...],
  "deliveryType": "pickup", // or "delivery"
  "paymentMethod": "card",
  "specialInstructions": "Ring doorbell"
}

Response:
{
  "orderId": "order-001",
  "status": "confirmed",
  "estimatedTime": 25
}
```

#### Get Order History
```
GET /orders

Response:
{
  "orders": [
    {
      "id": "order-001",
      "date": "2026-03-16T12:00:00Z",
      "status": "delivered",
      "total": 50.11,
      "items": [...]
    }
  ]
}
```

### Reservations

#### Get Available Slots
```
GET /reservations/slots?date=2026-03-20&partySize=4

Response:
{
  "slots": [
    { "time": "18:00", "available": true },
    { "time": "18:30", "available": true },
    { "time": "19:00", "available": false }
  ]
}
```

#### Make Reservation
```
POST /reservations

Request:
{
  "date": "2026-03-20",
  "time": "18:30",
  "partySize": 4,
  "name": "John Doe",
  "phone": "555-1234",
  "specialRequests": "High chair needed"
}

Response:
{
  "reservationId": "res-001",
  "confirmationCode": "ABC123"
}
```

### Restaurant Info

#### Get Restaurant Details
```
GET /restaurant

Response:
{
  "name": "La Bella Italia",
  "description": "Authentic Italian cuisine...",
  "address": "123 Main Street, City",
  "phone": "555-0000",
  "email": "info@restaurant.com",
  "coordinates": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "hours": {
    "monday": { "open": "11:00", "close": "22:00" },
    "tuesday": { "open": "11:00", "close": "22:00" },
    ...
  }
}
```

## Error Responses

All endpoints may return error responses:

```
{
  "error": {
    "code": "ITEM_NOT_FOUND",
    "message": "The requested item does not exist"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| ITEM_NOT_FOUND | 404 | Resource not found |
| VALIDATION_ERROR | 400 | Invalid request data |
| UNAUTHORIZED | 401 | Authentication required |
| SLOT_UNAVAILABLE | 409 | Reservation slot taken |
| SERVER_ERROR | 500 | Internal server error |

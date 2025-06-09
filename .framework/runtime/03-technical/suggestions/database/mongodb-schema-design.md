# MongoDB Schema Design Template

## Overview
Schema design patterns for MongoDB focusing on document-oriented modeling, performance optimization, and scalability.

## When to Suggest
- Flexible, evolving schemas
- Document-oriented data
- High-volume, high-velocity applications
- Real-time analytics
- Content management systems
- IoT data collection

## Core Patterns

### Document Design Principles
- Embed related data that's accessed together
- Reference data that's accessed separately
- Consider document size limits (16MB)
- Design for your queries, not relationships
- Denormalize for read performance

### User Document Pattern
```javascript
// User collection
{
  _id: ObjectId("..."),
  email: "user@example.com",
  username: "johndoe",
  passwordHash: "$2b$10$...",
  profile: {
    firstName: "John",
    lastName: "Doe",
    avatarUrl: "https://...",
    bio: "Software developer",
    dateOfBirth: ISODate("1990-01-01"),
    preferences: {
      theme: "dark",
      language: "en",
      notifications: {
        email: true,
        push: false
      }
    }
  },
  roles: ["user", "admin"],
  status: {
    isActive: true,
    isVerified: true,
    lastLoginAt: ISODate("2024-01-15T10:30:00Z"),
    loginCount: 42
  },
  metadata: {
    createdAt: ISODate("2023-01-01T00:00:00Z"),
    updatedAt: ISODate("2024-01-15T10:30:00Z"),
    version: 2
  }
}

// Indexes
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ username: 1 }, { unique: true })
db.users.createIndex({ "status.isActive": 1, "metadata.createdAt": -1 })
db.users.createIndex({ "roles": 1 })
```

### Embedding Pattern - Blog Post
```javascript
// Posts collection with embedded comments
{
  _id: ObjectId("..."),
  title: "Introduction to MongoDB",
  slug: "introduction-to-mongodb",
  content: "Full article content...",
  author: {
    _id: ObjectId("..."),
    username: "johndoe",
    displayName: "John Doe",
    avatarUrl: "https://..."
  },
  tags: ["mongodb", "database", "nosql"],
  category: "tutorials",
  
  // Embedded comments (limited)
  comments: [
    {
      _id: ObjectId("..."),
      text: "Great article!",
      author: {
        _id: ObjectId("..."),
        username: "jane",
        displayName: "Jane Smith"
      },
      createdAt: ISODate("2024-01-10T15:30:00Z"),
      likes: 5
    }
    // ... more comments
  ],
  commentCount: 25,  // Track total separately
  
  stats: {
    views: 1500,
    likes: 45,
    shares: 12
  },
  
  seo: {
    metaDescription: "Learn MongoDB basics...",
    keywords: ["mongodb", "tutorial"]
  },
  
  status: "published",
  publishedAt: ISODate("2024-01-01T09:00:00Z"),
  createdAt: ISODate("2023-12-20T10:00:00Z"),
  updatedAt: ISODate("2024-01-01T09:00:00Z")
}

// Separate collection for all comments (when scaling)
{
  _id: ObjectId("..."),
  postId: ObjectId("..."),
  text: "Comment text...",
  author: { /* embedded author info */ },
  parentCommentId: ObjectId("..."), // For threading
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}
```

### Reference Pattern - E-commerce
```javascript
// Products collection
{
  _id: ObjectId("..."),
  sku: "LAPTOP-001",
  name: "Pro Laptop 15",
  slug: "pro-laptop-15",
  description: "High-performance laptop...",
  
  // Reference to brand
  brandId: ObjectId("..."),
  
  // Embedded frequently accessed data
  pricing: {
    basePrice: 1299.99,
    currency: "USD",
    discount: {
      type: "percentage",
      value: 10,
      validUntil: ISODate("2024-02-01")
    }
  },
  
  // Denormalized category path for queries
  categories: [
    {
      _id: ObjectId("..."),
      name: "Electronics",
      path: "/electronics"
    },
    {
      _id: ObjectId("..."),
      name: "Computers",
      path: "/electronics/computers"
    },
    {
      _id: ObjectId("..."),
      name: "Laptops",
      path: "/electronics/computers/laptops"
    }
  ],
  
  attributes: {
    processor: "Intel i7",
    ram: "16GB",
    storage: "512GB SSD",
    display: "15.6 inch"
  },
  
  inventory: {
    quantity: 50,
    reservedQuantity: 5,
    warehouse: "main"
  },
  
  images: [
    {
      url: "https://...",
      alt: "Product front view",
      isPrimary: true
    }
  ],
  
  ratings: {
    average: 4.5,
    count: 125
  },
  
  status: "active",
  createdAt: ISODate("..."),
  updatedAt: ISODate("...")
}

// Orders collection with references
{
  _id: ObjectId("..."),
  orderNumber: "ORD-2024-00123",
  userId: ObjectId("..."),
  
  // Snapshot of user data at order time
  customer: {
    name: "John Doe",
    email: "john@example.com",
    phone: "+1234567890"
  },
  
  // Snapshot of product data at order time
  items: [
    {
      productId: ObjectId("..."),
      sku: "LAPTOP-001",
      name: "Pro Laptop 15",
      price: 1169.99,
      quantity: 1,
      subtotal: 1169.99
    }
  ],
  
  shipping: {
    address: {
      street: "123 Main St",
      city: "New York",
      state: "NY",
      zipCode: "10001",
      country: "US"
    },
    method: "express",
    trackingNumber: "1234567890",
    estimatedDelivery: ISODate("2024-01-20")
  },
  
  payment: {
    method: "credit_card",
    status: "completed",
    transactionId: "txn_123456"
  },
  
  totals: {
    subtotal: 1169.99,
    tax: 93.60,
    shipping: 15.00,
    total: 1278.59
  },
  
  status: "shipped",
  statusHistory: [
    {
      status: "pending",
      timestamp: ISODate("2024-01-15T10:00:00Z")
    },
    {
      status: "processing",
      timestamp: ISODate("2024-01-15T10:30:00Z")
    },
    {
      status: "shipped",
      timestamp: ISODate("2024-01-16T14:00:00Z")
    }
  ],
  
  createdAt: ISODate("2024-01-15T10:00:00Z"),
  updatedAt: ISODate("2024-01-16T14:00:00Z")
}
```

### Bucket Pattern - Time Series Data
```javascript
// Sensor data bucketed by hour
{
  _id: ObjectId("..."),
  sensorId: "sensor-001",
  bucketStartTime: ISODate("2024-01-15T10:00:00Z"),
  bucketEndTime: ISODate("2024-01-15T11:00:00Z"),
  
  measurements: [
    {
      timestamp: ISODate("2024-01-15T10:00:30Z"),
      temperature: 22.5,
      humidity: 45.2,
      pressure: 1013.25
    },
    {
      timestamp: ISODate("2024-01-15T10:01:30Z"),
      temperature: 22.6,
      humidity: 45.1,
      pressure: 1013.20
    }
    // ... more measurements
  ],
  
  stats: {
    measurementCount: 120,
    temperature: {
      min: 22.1,
      max: 23.2,
      avg: 22.6,
      sum: 2712
    },
    humidity: {
      min: 44.5,
      max: 46.2,
      avg: 45.3,
      sum: 5436
    }
  }
}

// Index for time-based queries
db.sensor_data.createIndex({ 
  sensorId: 1, 
  bucketStartTime: -1 
})
```

### Polymorphic Pattern - Notifications
```javascript
// Notifications collection with different types
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),
  type: "order_shipped",
  
  // Common fields
  title: "Your order has been shipped!",
  message: "Order #12345 is on its way",
  isRead: false,
  createdAt: ISODate("2024-01-15T14:00:00Z"),
  
  // Type-specific data
  data: {
    orderId: ObjectId("..."),
    orderNumber: "ORD-2024-00123",
    trackingNumber: "1234567890",
    estimatedDelivery: ISODate("2024-01-20")
  }
}

{
  _id: ObjectId("..."),
  userId: ObjectId("..."),
  type: "friend_request",
  
  title: "New friend request",
  message: "Jane Smith wants to connect",
  isRead: true,
  createdAt: ISODate("2024-01-14T10:00:00Z"),
  
  data: {
    fromUserId: ObjectId("..."),
    fromUsername: "janesmith",
    fromDisplayName: "Jane Smith",
    fromAvatarUrl: "https://..."
  }
}
```

### Tree Structure Pattern - Categories
```javascript
// Materialized path pattern
{
  _id: ObjectId("..."),
  name: "Laptops",
  path: ",Electronics,Computers,Laptops,",
  parent: "Computers",
  order: 1
}

// Array of ancestors pattern
{
  _id: ObjectId("..."),
  name: "Laptops",
  ancestors: [
    { _id: ObjectId("..."), name: "Electronics" },
    { _id: ObjectId("..."), name: "Computers" }
  ],
  parent: ObjectId("...")
}

// Queries
// Find all descendants of Electronics
db.categories.find({ path: /,Electronics,/ })

// Find direct children
db.categories.find({ parent: "Electronics" })
```

### Aggregation Pipeline Patterns

#### Faceted Search
```javascript
db.products.aggregate([
  {
    $match: {
      status: "active",
      "pricing.basePrice": { $gte: 100, $lte: 1000 }
    }
  },
  {
    $facet: {
      // Results
      products: [
        { $skip: 0 },
        { $limit: 20 },
        {
          $project: {
            name: 1,
            slug: 1,
            pricing: 1,
            images: { $slice: ["$images", 1] },
            ratings: 1
          }
        }
      ],
      
      // Category facet
      categories: [
        { $unwind: "$categories" },
        {
          $group: {
            _id: "$categories._id",
            name: { $first: "$categories.name" },
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } }
      ],
      
      // Price range facet
      priceRanges: [
        {
          $bucket: {
            groupBy: "$pricing.basePrice",
            boundaries: [0, 100, 500, 1000, 5000],
            default: "5000+",
            output: { count: { $sum: 1 } }
          }
        }
      ],
      
      // Total count
      totalCount: [
        { $count: "total" }
      ]
    }
  }
])
```

#### Real-time Analytics
```javascript
// User activity aggregation
db.user_activities.aggregate([
  {
    $match: {
      timestamp: {
        $gte: ISODate("2024-01-15T00:00:00Z"),
        $lt: ISODate("2024-01-16T00:00:00Z")
      }
    }
  },
  {
    $group: {
      _id: {
        hour: { $hour: "$timestamp" },
        action: "$action"
      },
      count: { $sum: 1 },
      uniqueUsers: { $addToSet: "$userId" }
    }
  },
  {
    $project: {
      hour: "$_id.hour",
      action: "$_id.action",
      count: 1,
      uniqueUserCount: { $size: "$uniqueUsers" }
    }
  },
  {
    $sort: { hour: 1, action: 1 }
  }
])
```

### Index Strategies
```javascript
// Compound indexes for common queries
db.products.createIndex({ 
  status: 1, 
  "pricing.basePrice": 1, 
  "ratings.average": -1 
})

// Text search index
db.products.createIndex({ 
  name: "text", 
  description: "text" 
})

// Geospatial index
db.stores.createIndex({ location: "2dsphere" })

// TTL index for automatic deletion
db.sessions.createIndex(
  { createdAt: 1 }, 
  { expireAfterSeconds: 3600 }
)

// Partial index
db.users.createIndex(
  { email: 1 },
  { 
    partialFilterExpression: { 
      "status.isActive": true 
    }
  }
)
```

### Schema Validation
```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "username", "passwordHash"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        username: {
          bsonType: "string",
          minLength: 3,
          maxLength: 30
        },
        roles: {
          bsonType: "array",
          items: {
            bsonType: "string",
            enum: ["user", "admin", "moderator"]
          }
        },
        "profile.age": {
          bsonType: "int",
          minimum: 0,
          maximum: 150
        }
      }
    }
  }
})
```

### Change Streams Pattern
```javascript
// Watch for changes
const changeStream = db.orders.watch([
  {
    $match: {
      operationType: { $in: ["insert", "update"] },
      "fullDocument.status": "completed"
    }
  }
], {
  fullDocument: "updateLookup"
});

changeStream.on("change", (change) => {
  console.log("Order completed:", change.fullDocument);
  // Trigger downstream processes
});
```

## Key Benefits
- Flexible schema evolution
- Horizontal scalability
- High performance for reads
- Natural data representation
- Built-in replication and sharding
- Rich query capabilities
- Change streams for real-time apps

## Best Practices
- Design for your queries
- Embed when data is accessed together
- Use references for large or frequently changing data
- Consider document size limits
- Index appropriately
- Use aggregation pipelines for complex queries
- Monitor and optimize based on usage patterns
# MongoDB API Patterns

This document outlines API design patterns specific to MongoDB integration in the Nexus MCP server, focusing on clinical trial metadata management.

## Query API Design for MongoDB Collections

### Basic Query Structure
```typescript
interface MongoQuery {
  collection: string;
  filter: FilterQuery;
  options?: QueryOptions;
}

interface QueryOptions {
  projection?: Projection;
  sort?: Sort;
  limit?: number;
  skip?: number;
  hint?: IndexHint;
  explain?: boolean;
}
```

### Clinical Trial Collections

#### Trials Collection Query
```http
POST /api/v1/mongodb/query
Content-Type: application/json

{
  "collection": "trials",
  "filter": {
    "status": "active",
    "phase": { "$in": ["II", "III"] },
    "startDate": { "$gte": "2024-01-01" }
  },
  "options": {
    "projection": {
      "trialId": 1,
      "title": 1,
      "phase": 1,
      "enrollment": 1
    },
    "sort": { "startDate": -1 },
    "limit": 20
  }
}
```

#### Signals Collection Query
```http
POST /api/v1/mongodb/query
Content-Type: application/json

{
  "collection": "signals",
  "filter": {
    "$and": [
      { "trialId": "NCT12345678" },
      { "severity": { "$in": ["high", "critical"] } },
      { "status": "open" },
      { "detectedAt": { "$gte": "2024-05-01" } }
    ]
  },
  "options": {
    "sort": { "severity": -1, "detectedAt": -1 }
  }
}
```

### Advanced Query Patterns

#### Text Search
```json
{
  "collection": "signals",
  "filter": {
    "$text": { "$search": "cardiac adverse event" }
  },
  "options": {
    "projection": { "score": { "$meta": "textScore" } },
    "sort": { "score": { "$meta": "textScore" } }
  }
}
```

#### Geospatial Query (for site locations)
```json
{
  "collection": "trial_sites",
  "filter": {
    "location": {
      "$near": {
        "$geometry": {
          "type": "Point",
          "coordinates": [-73.935242, 40.730610]
        },
        "$maxDistance": 50000
      }
    }
  }
}
```

#### Array Operations
```json
{
  "collection": "datasets",
  "filter": {
    "variables": {
      "$elemMatch": {
        "name": "AGE",
        "type": "numeric",
        "required": true
      }
    }
  }
}
```

## Aggregation Pipeline Exposure

### Aggregation Endpoint
```http
POST /api/v1/mongodb/aggregate
Content-Type: application/json

{
  "collection": "signals",
  "pipeline": [...],
  "options": {
    "allowDiskUse": true,
    "maxTimeMS": 60000
  }
}
```

### Signal Analysis Pipeline
```json
{
  "collection": "signals",
  "pipeline": [
    {
      "$match": {
        "trialId": "NCT12345678",
        "detectedAt": { "$gte": "2024-01-01" }
      }
    },
    {
      "$group": {
        "_id": {
          "severity": "$severity",
          "category": "$category"
        },
        "count": { "$sum": 1 },
        "avgResolutionTime": {
          "$avg": {
            "$subtract": ["$resolvedAt", "$detectedAt"]
          }
        }
      }
    },
    {
      "$sort": { "count": -1 }
    },
    {
      "$project": {
        "severity": "$_id.severity",
        "category": "$_id.category",
        "count": 1,
        "avgResolutionDays": {
          "$divide": ["$avgResolutionTime", 86400000]
        }
      }
    }
  ]
}
```

### Trial Enrollment Trends
```json
{
  "collection": "trial_enrollments",
  "pipeline": [
    {
      "$match": {
        "trialId": "NCT12345678"
      }
    },
    {
      "$group": {
        "_id": {
          "$dateToString": {
            "format": "%Y-%m",
            "date": "$enrollmentDate"
          }
        },
        "enrolled": { "$sum": 1 },
        "screenFailures": {
          "$sum": {
            "$cond": ["$screenFailure", 1, 0]
          }
        }
      }
    },
    {
      "$sort": { "_id": 1 }
    },
    {
      "$group": {
        "_id": null,
        "months": { "$push": "$_id" },
        "enrollments": { "$push": "$enrolled" },
        "failures": { "$push": "$screenFailures" },
        "cumulativeEnrollment": {
          "$push": {
            "$sum": {
              "$slice": ["$enrolled", { "$add": ["$_id", 1] }]
            }
          }
        }
      }
    }
  ]
}
```

### Statistical Analysis Pipeline
```json
{
  "collection": "measurements",
  "pipeline": [
    {
      "$match": {
        "datasetId": "dataset_123",
        "variable": "BLOOD_PRESSURE_SYSTOLIC"
      }
    },
    {
      "$facet": {
        "statistics": [
          {
            "$group": {
              "_id": null,
              "count": { "$sum": 1 },
              "mean": { "$avg": "$value" },
              "stdDev": { "$stdDevPop": "$value" },
              "min": { "$min": "$value" },
              "max": { "$max": "$value" }
            }
          }
        ],
        "percentiles": [
          {
            "$group": {
              "_id": null,
              "values": { "$push": "$value" }
            }
          },
          {
            "$project": {
              "p25": { "$percentile": { "input": "$values", "p": [0.25] } },
              "p50": { "$percentile": { "input": "$values", "p": [0.50] } },
              "p75": { "$percentile": { "input": "$values", "p": [0.75] } },
              "p95": { "$percentile": { "input": "$values", "p": [0.95] } }
            }
          }
        ],
        "outliers": [
          {
            "$group": {
              "_id": null,
              "mean": { "$avg": "$value" },
              "stdDev": { "$stdDevPop": "$value" }
            }
          },
          {
            "$lookup": {
              "from": "measurements",
              "let": {
                "upperBound": { "$add": ["$mean", { "$multiply": ["$stdDev", 3] }] },
                "lowerBound": { "$subtract": ["$mean", { "$multiply": ["$stdDev", 3] }] }
              },
              "pipeline": [
                {
                  "$match": {
                    "$expr": {
                      "$or": [
                        { "$gt": ["$value", "$$upperBound"] },
                        { "$lt": ["$value", "$$lowerBound"] }
                      ]
                    }
                  }
                }
              ],
              "as": "outliers"
            }
          }
        ]
      }
    }
  ]
}
```

## Bulk Operations Handling

### Bulk Write Endpoint
```http
POST /api/v1/mongodb/bulk
Content-Type: application/json

{
  "collection": "signals",
  "operations": [
    {
      "insertOne": {
        "document": {
          "trialId": "NCT12345678",
          "severity": "high",
          "category": "safety",
          "description": "Elevated liver enzymes"
        }
      }
    },
    {
      "updateMany": {
        "filter": { "trialId": "NCT12345678", "status": "pending" },
        "update": { "$set": { "assignedTo": "reviewer_123" } }
      }
    },
    {
      "deleteOne": {
        "filter": { "_id": "signal_456", "status": "duplicate" }
      }
    }
  ],
  "options": {
    "ordered": false,
    "writeConcern": { "w": "majority" }
  }
}
```

### Bulk Signal Actions
```json
{
  "collection": "signal_actions",
  "operations": [
    {
      "insertMany": {
        "documents": [
          {
            "signalId": "signal_123",
            "action": "investigate",
            "assignedTo": "user_456",
            "dueDate": "2024-07-01"
          },
          {
            "signalId": "signal_124",
            "action": "close",
            "reason": "false_positive",
            "closedBy": "user_789"
          }
        ]
      }
    }
  ]
}
```

### Bulk Update with Pipeline
```json
{
  "collection": "datasets",
  "operations": [
    {
      "updateMany": {
        "filter": { "trialId": "NCT12345678" },
        "update": [
          {
            "$set": {
              "lastModified": "$$NOW",
              "modificationCount": { "$add": ["$modificationCount", 1] }
            }
          }
        ]
      }
    }
  ]
}
```

## Transaction Support in APIs

### Transaction Wrapper
```http
POST /api/v1/mongodb/transaction
Content-Type: application/json

{
  "operations": [
    {
      "collection": "signals",
      "operation": "insertOne",
      "document": {
        "trialId": "NCT12345678",
        "severity": "critical",
        "description": "Serious adverse event"
      }
    },
    {
      "collection": "signal_history",
      "operation": "insertOne",
      "document": {
        "signalId": "{{operations[0].insertedId}}",
        "action": "created",
        "timestamp": "$$NOW",
        "userId": "user_123"
      }
    },
    {
      "collection": "notifications",
      "operation": "insertMany",
      "documents": [
        {
          "type": "signal_alert",
          "severity": "critical",
          "recipients": ["safety_team", "medical_monitor"],
          "signalId": "{{operations[0].insertedId}}"
        }
      ]
    }
  ],
  "options": {
    "readConcern": { "level": "snapshot" },
    "writeConcern": { "w": "majority" },
    "maxCommitTimeMS": 5000
  }
}
```

### Signal Workflow Transaction
```json
{
  "operations": [
    {
      "collection": "signals",
      "operation": "updateOne",
      "filter": { "_id": "signal_123" },
      "update": {
        "$set": {
          "status": "investigating",
          "investigator": "user_456",
          "investigationStarted": "$$NOW"
        }
      }
    },
    {
      "collection": "signal_assignments",
      "operation": "insertOne",
      "document": {
        "signalId": "signal_123",
        "assignedTo": "user_456",
        "assignedBy": "user_789",
        "assignedAt": "$$NOW"
      }
    },
    {
      "collection": "user_workload",
      "operation": "updateOne",
      "filter": { "userId": "user_456" },
      "update": {
        "$inc": { "activeSignals": 1 },
        "$push": {
          "assignments": {
            "signalId": "signal_123",
            "assignedAt": "$$NOW"
          }
        }
      }
    }
  ]
}
```

## Cursor-Based Pagination for Large Datasets

### Cursor Implementation
```typescript
interface CursorPagination {
  cursor?: string; // Base64 encoded last document ID + sort value
  limit: number;
  direction?: 'forward' | 'backward';
}
```

### Signal Pagination Example
```http
GET /api/v1/signals?cursor=eyJpZCI6IjUwN2YxZjc3YmNmODZjZDc5OTQzOTAxMSIsInNvcnQiOiIyMDI0LTA2LTA4VDEwOjAwOjAwWiJ9&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6IjUwN2YxZjc3YmNmODZjZDc5OTQzOTAzMSIsInNvcnQiOiIyMDI0LTA2LTA3VDEwOjAwOjAwWiJ9",
    "prevCursor": "eyJpZCI6IjUwN2YxZjc3YmNmODZjZDc5OTQzOTAwMSIsInNvcnQiOiIyMDI0LTA2LTA5VDEwOjAwOjAwWiJ9",
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Cursor Generation Logic
```typescript
function generateCursor(lastDoc: any, sortField: string): string {
  const cursorData = {
    id: lastDoc._id,
    sort: lastDoc[sortField]
  };
  return Buffer.from(JSON.stringify(cursorData)).toString('base64');
}

function parseCursor(cursor: string): CursorData {
  return JSON.parse(Buffer.from(cursor, 'base64').toString());
}
```

### Efficient Large Dataset Query
```json
{
  "collection": "measurements",
  "filter": {
    "$and": [
      { "datasetId": "dataset_123" },
      {
        "$or": [
          { "createdAt": { "$lt": "{{cursor.sort}}" } },
          {
            "$and": [
              { "createdAt": "{{cursor.sort}}" },
              { "_id": { "$gt": "{{cursor.id}}" } }
            ]
          }
        ]
      }
    ]
  },
  "options": {
    "sort": { "createdAt": -1, "_id": 1 },
    "limit": 100
  }
}
```

## Real-time Change Streams API

### Change Stream Subscription
```http
WebSocket: /api/v1/mongodb/changes

{
  "action": "subscribe",
  "streams": [
    {
      "collection": "signals",
      "pipeline": [
        {
          "$match": {
            "operationType": { "$in": ["insert", "update"] },
            "fullDocument.trialId": "NCT12345678",
            "fullDocument.severity": { "$in": ["high", "critical"] }
          }
        }
      ]
    }
  ]
}
```

### Change Event Format
```json
{
  "stream": "signals",
  "event": {
    "_id": {
      "_data": "826483F4C8000000012B022C0100296E5A1004ABCD"
    },
    "operationType": "insert",
    "clusterTime": "7234567890123456789",
    "fullDocument": {
      "_id": "signal_999",
      "trialId": "NCT12345678",
      "severity": "critical",
      "category": "safety",
      "detectedAt": "2024-06-08T10:00:00Z"
    },
    "ns": {
      "db": "nexus_research",
      "coll": "signals"
    }
  }
}
```

### Real-time Dashboard Updates
```typescript
// Subscribe to multiple collections
{
  "action": "subscribe",
  "streams": [
    {
      "collection": "signals",
      "pipeline": [
        { "$match": { "operationType": "insert" } },
        { "$project": { "fullDocument": 1 } }
      ]
    },
    {
      "collection": "signal_actions",
      "pipeline": [
        {
          "$match": {
            "operationType": "insert",
            "fullDocument.action": { "$in": ["escalate", "close"] }
          }
        }
      ]
    },
    {
      "collection": "trial_enrollments",
      "pipeline": [
        {
          "$match": {
            "$or": [
              { "operationType": "insert" },
              {
                "operationType": "update",
                "updateDescription.updatedFields.status": { "$exists": true }
              }
            ]
          }
        }
      ]
    }
  ]
}
```

## Index Management Endpoints

### List Indexes
```http
GET /api/v1/mongodb/indexes/{collection}

Response:
{
  "indexes": [
    {
      "name": "_id_",
      "key": { "_id": 1 },
      "unique": true
    },
    {
      "name": "trialId_severity_idx",
      "key": { "trialId": 1, "severity": -1 },
      "partialFilterExpression": { "status": "active" }
    },
    {
      "name": "text_search_idx",
      "key": { "description": "text", "category": "text" },
      "weights": { "description": 10, "category": 5 }
    }
  ]
}
```

### Create Index
```http
POST /api/v1/mongodb/indexes/{collection}
Content-Type: application/json

{
  "key": {
    "trialId": 1,
    "detectedAt": -1
  },
  "options": {
    "name": "trial_timeline_idx",
    "background": true,
    "expireAfterSeconds": 31536000,
    "partialFilterExpression": {
      "status": { "$in": ["active", "pending"] }
    }
  }
}
```

### Analyze Index Usage
```http
GET /api/v1/mongodb/indexes/{collection}/usage

Response:
{
  "indexUsage": [
    {
      "name": "trialId_severity_idx",
      "operations": 15234,
      "since": "2024-06-01T00:00:00Z",
      "avgExecutionTime": 12,
      "inefficientQueries": 3
    }
  ],
  "recommendations": [
    {
      "action": "create",
      "reason": "Frequent queries on unindexed fields",
      "suggestedIndex": {
        "key": { "category": 1, "status": 1 },
        "estimatedImprovement": "75%"
      }
    }
  ]
}
```

## Data Export/Import APIs

### Export API
```http
POST /api/v1/mongodb/export
Content-Type: application/json

{
  "collection": "signals",
  "filter": {
    "trialId": "NCT12345678",
    "detectedAt": { "$gte": "2024-01-01" }
  },
  "format": "json", // json, csv, parquet
  "options": {
    "compression": "gzip",
    "includeMetadata": true,
    "fields": ["_id", "trialId", "severity", "category", "description", "detectedAt"]
  }
}

Response:
{
  "exportId": "exp_123456",
  "status": "processing",
  "estimatedRows": 5000,
  "estimatedSize": "25MB"
}
```

### Export Status
```http
GET /api/v1/mongodb/export/{exportId}

Response:
{
  "exportId": "exp_123456",
  "status": "completed",
  "downloadUrl": "https://storage.nexus-cmp.com/exports/exp_123456.json.gz",
  "expiresAt": "2024-06-15T10:00:00Z",
  "metadata": {
    "rows": 4823,
    "size": "23.4MB",
    "duration": 45,
    "compressed": true
  }
}
```

### Import API
```http
POST /api/v1/mongodb/import
Content-Type: multipart/form-data

{
  "collection": "external_signals",
  "file": <file>,
  "options": {
    "format": "csv",
    "mapping": {
      "Signal ID": "_id",
      "Trial": "trialId",
      "Severity": "severity",
      "Description": "description"
    },
    "validation": {
      "required": ["trialId", "severity"],
      "unique": ["_id"],
      "transforms": {
        "severity": "lowercase",
        "detectedAt": "parseDate"
      }
    },
    "onError": "skip", // skip, abort, log
    "batchSize": 1000
  }
}
```

### Import Progress
```http
GET /api/v1/mongodb/import/{importId}

Response:
{
  "importId": "imp_789012",
  "status": "processing",
  "progress": {
    "total": 10000,
    "processed": 7500,
    "successful": 7450,
    "failed": 50,
    "skipped": 0
  },
  "errors": [
    {
      "row": 1234,
      "error": "Missing required field: trialId",
      "data": { "Signal ID": "SIG001", "Severity": "high" }
    }
  ]
}
```

## Performance Optimization Patterns

### Query Optimization Hints
```json
{
  "collection": "signals",
  "filter": { "trialId": "NCT12345678" },
  "options": {
    "hint": { "trialId": 1, "severity": -1 },
    "maxTimeMS": 5000,
    "readPreference": "secondaryPreferred"
  }
}
```

### Aggregation Optimization
```json
{
  "pipeline": [
    { "$match": { "trialId": "NCT12345678" } }, // Early filtering
    { "$project": { // Reduce document size early
      "severity": 1,
      "category": 1,
      "detectedAt": 1
    }},
    { "$group": {
      "_id": "$severity",
      "count": { "$sum": 1 }
    }},
    { "$sort": { "count": -1 } }
  ],
  "options": {
    "allowDiskUse": true, // For large aggregations
    "hint": { "trialId": 1 }, // Force index usage
    "readConcern": { "level": "local" } // Performance over consistency
  }
}
```

### Batch Processing Pattern
```typescript
async function processBatchQuery(filter: any, batchSize: number = 1000) {
  let lastId = null;
  let hasMore = true;
  
  while (hasMore) {
    const query = {
      ...filter,
      ...(lastId && { _id: { $gt: lastId } })
    };
    
    const batch = await collection
      .find(query)
      .sort({ _id: 1 })
      .limit(batchSize)
      .toArray();
    
    if (batch.length < batchSize) {
      hasMore = false;
    }
    
    if (batch.length > 0) {
      lastId = batch[batch.length - 1]._id;
      yield batch;
    }
  }
}
```

## Best Practices

### Query Design
- Always use indexes for filtering
- Project only required fields
- Use aggregation for complex calculations
- Implement query timeouts
- Monitor slow query logs

### Data Modeling for APIs
- Denormalize for read performance
- Use embedded documents judiciously
- Implement soft deletes
- Version sensitive documents
- Use appropriate data types

### Error Handling
- Return meaningful error messages
- Include query execution stats in errors
- Implement retry logic for transient failures
- Log all database errors
- Monitor connection pool health

### Security
- Validate all query inputs
- Prevent NoSQL injection
- Implement field-level security
- Audit sensitive operations
- Encrypt data in transit and at rest
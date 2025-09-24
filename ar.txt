┌────────────────────────────┐
│  EventBridge Rule (15 min) │
└──────────────┬─────────────┘
               │ triggers
               ▼
      ┌───────────────────┐
      │ Scheduler Lambda  │
      │ - Scan DynamoDB   │
      │ - Fetch ~70 alerts│
      │ - Push to SQS     │
      └─────────┬─────────┘
                │ 70 msgs
                ▼
        ┌────────────────┐
        │     SQS Queue  │
        │ (buffer + retry│
        │   + DLQ option)│
        └────────┬───────┘
                 │ invokes
                 ▼
     ┌──────────────────────────┐
     │ Worker Lambda (per alert)│
     │ - Get Splunk saved search│
     │ - Run query (Export/Jobs)│
     │ - Parse result OK/KO     │
     │ - Check DynamoDB state   │
     │ - Create ServiceNow ticket
     │   only on OK→KO change   │
     │ - Update checkpoint table│
     └────────────┬─────────────┘
                  │
                  ▼
        ┌───────────────────────┐
        │ DynamoDB Checkpoint   │
        │ - alert_name          │
        │ - last_status         │
        │ - last_ticket_id      │
        │ - last_updated        │
        └───────────────────────┘

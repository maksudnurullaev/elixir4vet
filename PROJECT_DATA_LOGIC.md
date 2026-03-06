# Data logic and definitions
```
USERS can be representatives of ORGANIZATIONS.
USER can be owner of ANIMAL.
ANIMAL always has at least one owner who is USER.
EVENT always belongs to ANIMAL:
    - Event types:
        - Registration - Initial animal registration
        - Microchipping - Microchip implantation
        - Sterilization - Sterilization procedures
        - Neutering - Neutering/castration procedures
        - Vaccination - Vaccination events
        - Examination - Medical check-ups and examinations
        - Surgery - Surgical procedures
        - Bandage - Bandaging and wound care
        - IV - Intravenous treatments
        - Lost - Animal reported lost
        - Found - Animal found/recovered
        - RIP - Animal deceased
        - Other - Other event types not listed above
EVENT may have PHOTOS attached to them.
```

---

## Diagram

```mermaid
erDiagram
    USER {
        int id
        string email
        string role
    }
    ORGANIZATION {
        int id
        string name
    }
    ANIMAL {
        int id
        string name
    }
    EVENT {
        int id
        string type
        date date
        string notes
    }
    PHOTO {
        int id
        string url
    }

    USER ||--o{ ORGANIZATION : "representative of"
    USER ||--o{ ANIMAL : "owner of (1+)"
    ANIMAL ||--o{ EVENT : "has"
    EVENT ||--o{ PHOTO : "may have"
```

### Event types

| Type | Description |
|---|---|
| Registration | Initial animal registration |
| Microchipping | Microchip implantation |
| Sterilization | Sterilization procedures |
| Neutering | Neutering/castration procedures |
| Vaccination | Vaccination events |
| Examination | Medical check-ups and examinations |
| Surgery | Surgical procedures |
| Bandage | Bandaging and wound care |
| IV | Intravenous treatments |
| Lost | Animal reported lost |
| Found | Animal found/recovered |
| RIP | Animal deceased |
| Other | Other event types not listed above |
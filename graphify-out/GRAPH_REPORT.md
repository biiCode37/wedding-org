# Graph Report - WEDDING_ORGANIZER  (2026-08-30)

## Corpus Check
- 106 files · ~128,260 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 552 nodes · 542 edges · 79 communities (37 shown, 42 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `785610c9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Use Cases & State Machines
- AI Code Executor
- graphify.js
- bash
- Feature Flag Strategy
- Incident Response Playbook
- PWS Check-in Offline Strategy v0.1
- PWS Client Writable Fields v0.1
- PWS Data Governance and Privacy v0.1
- PWS Deployment Guide and Runbook v0.1
- Product Glossary
- Backup & Retention Strategy
- Product Requirements Document
- Release Roadmap & Zero-Cost Strategy
- design_system.py
- High Impact
- ui-ux-pro-max
- Code Correctness Rules
- DesignSystemGenerator
- Code Security Skill
- Prevent Insecure Deserialization
- Prevent Path Traversal
- Prevent Cross-Site Scripting (XSS)
- General Best Practices for Avoiding Race Conditions
- Prevent XML External Entity (XXE) Injection
- Code Best Practices
- terraform-gcp.md
- Categories
- Prevent Cross-Site Request Forgery
- Secure Kubernetes Configurations
- Secure Azure Terraform Configurations
- Python
- Prevent SQL Injection
- How to Fetch Documentation
- Code Security
- Secure Docker Configurations
- Avoid Insecure Cryptography
- Use Secure Transport
- Prevent Server-Side Request Forgery (SSRF)
- Secure AWS Terraform Configurations
- How to Fetch Documentation
- Prevent Command Injection
- Secure GitHub Actions
- Ensure Memory Safety
- Prevent Regular Expression DoS (ReDoS)
- plugin
- code-injection.md
- mcp.json
- 10. Insecure Cryptography
- 11. Insecure Transport
- 12. Server-Side Request Forgery
- 13. JWT Authentication
- 14. Cross-Site Request Forgery
- 15. Prototype Pollution
- 16. Unsafe Functions
- 17. Terraform AWS Security
- 18. Terraform Azure Security
- 19. Terraform GCP Security
- 1. SQL Injection
- 20. Kubernetes Security
- 21. Docker Security
- 24. Race Conditions
- 25. Code Correctness
- 26. Best Practices
- 27. Performance
- 28. Maintainability
- 2. Command Injection
- 3. Cross-Site Scripting
- 4. XML External Entity
- 5. Path Traversal
- 6. Insecure Deserialization
- 7. Code Injection
- 8. Hardcoded Secrets
- 9. Memory Safety
- authentication-jwt.md
- maintainability.md
- prototype-pollution.md
- _template.md
- unsafe-functions.md

## God Nodes (most connected - your core abstractions)
1. `Code Security` - 31 edges
2. `High Impact` - 14 edges
3. `DesignSystemGenerator` - 11 edges
4. `bash` - 11 edges
5. `Critical Impact` - 10 edges
6. `Code Best Practices` - 10 edges
7. `Secure Kubernetes Configurations` - 9 edges
8. `Secure Azure Terraform Configurations` - 9 edges
9. `ui-ux-pro-max` - 9 edges
10. `search()` - 9 edges

## Surprising Connections (you probably didn't know these)
- `AI Code Executor` --references--> `PWS AI Agent Operating Rules v0.1`  [EXTRACTED]
  AGENTS.md → docs/PWS_AI_Agent_Operating_Rules_v0.1.md
- `AI Code Executor` --references--> `PWS Domain Services + Business Rules v0.1`  [EXTRACTED]
  AGENTS.md → docs/PWS_Domain_Services_Business_Rules_v0.1.md
- `AI Code Executor` --references--> `PWS API Contract v0.1`  [EXTRACTED]
  AGENTS.md → docs/PWS_API_Contract_v0.1.md
- `AI Code Executor` --references--> `PWS Architecture Decision Record v0.1`  [EXTRACTED]
  AGENTS.md → docs/PWS_Architecture_Decision_Record_v0.1.md
- `AI Code Executor` --references--> `PWS Authorization + RLS Specification v0.1`  [EXTRACTED]
  AGENTS.md → docs/PWS_Authorization_RLS_Specification_v0.1_updated.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **PWS Documentation Hierarchy** — docs_pws_domain_core_data_multi_tenant_rbac_v0_1, docs_pws_architecture_decision_record_v0_1, docs_pws_authorization_rls_specification_v0_1_updated, docs_pws_api_contract_v0_1, docs_pws_domain_services_business_rules_v0_1, docs_pws_engineering_implementation_blueprint_v0_1 [EXTRACTED 1.00]
- **Core Domain Logic & Invariants** — docs_pws_physical_database_schema_v0_1_db_schema, docs_pws_use_cases_state_machines_v0_1_use_cases, docs_pws_testing_acceptance_criteria_v0_1_acceptance_criteria [EXTRACTED 0.95]
- **Operational & Reliability Framework** — docs_pws_incident_response_playbook_v0_1_incident_response, docs_pws_observability_architecture_v0_1_observability_arch, docs_pws_operations_backup_retention_v0_1_backup_strategy [INFERRED 0.85]

## Communities (79 total, 42 thin omitted)

### Community 0 - "Use Cases & State Machines"
Cohesion: 0.22
Nodes (9): Integration Test Plan, Messaging Architecture, Payment Architecture, Physical Database Schema, Public RSVP Expiry Spec, Security & NFR Specification, Testing & Acceptance Criteria, UI/UX Specification (+1 more)

### Community 1 - "AI Code Executor"
Cohesion: 0.44
Nodes (9): AI Code Executor, devmode branch, PWS AI Agent Operating Rules v0.1, PWS API Contract v0.1, PWS Architecture Decision Record v0.1, PWS Authorization + RLS Specification v0.1, PWS Domain Model + Core Entity/Data Model + Multi-Tenant/RBAC Model v0.1, PWS Domain Services + Business Rules v0.1 (+1 more)

### Community 3 - "bash"
Cohesion: 0.05
Nodes (42): git add *, git branch *, git checkout *, git commit *, git diff *, git log *, git merge *, git pull * (+34 more)

### Community 14 - "design_system.py"
Cohesion: 0.08
Nodes (33): BM25, detect_domain(), _load_csv(), Lowercase, split, remove punctuation, filter short words, Build BM25 index from documents, Score all documents against query, Load CSV and return list of dicts, Core search function using BM25 (+25 more)

### Community 15 - "High Impact"
Cohesion: 0.06
Nodes (34): 10. Insecure Cryptography (insecure-crypto), 11. Insecure Transport (insecure-transport), 12. Server-Side Request Forgery (ssrf), 13. JWT Authentication (authentication-jwt), 14. Cross-Site Request Forgery (csrf), 15. Prototype Pollution (prototype-pollution), 16. Unsafe Functions (unsafe-functions), 17. Terraform AWS Security (terraform-aws) (+26 more)

### Community 16 - "ui-ux-pro-max"
Cohesion: 0.07
Nodes (29): Accessibility, Available Domains, Available Stacks, Common Rules for Professional UI, Example Workflow, How to Use This Skill, Icons & Visual Elements, Interaction (+21 more)

### Community 17 - "Code Correctness Rules"
Cohesion: 0.08
Nodes (23): Assignment in Condition, ato* Functions, Bash, C, Code Correctness Rules, Elixir: Atom Exhaustion, Go, Integer Overflow from Atoi (+15 more)

### Community 18 - "DesignSystemGenerator"
Cohesion: 0.16
Nodes (9): DesignSystemGenerator, Select best matching result based on priority keywords., Extract results list from search result dict., Generate complete design system recommendation., Generates design system recommendations from aggregated searches., Load reasoning rules from CSV., Execute searches across multiple domains., Find matching reasoning rule for a category. (+1 more)

### Community 19 - "Code Security Skill"
Cohesion: 0.12
Nodes (15): Acknowledgments, Categories (28 Total), Code Security Skill, Creating a New Rule, Critical Impact, For Contributors, For End Users, High Impact (+7 more)

### Community 20 - "Prevent Insecure Deserialization"
Cohesion: 0.13
Nodes (14): BinaryFormatter Deserialization, General Prevention Guidelines, Language: C#, Language: Java, Language: JavaScript / TypeScript, Language: PHP, Language: Python, Language: Ruby (+6 more)

### Community 21 - "Prevent Path Traversal"
Cohesion: 0.14
Nodes (13): File Inclusion (LFI/RFI), filepath.Clean Misuse, HttpServlet Path Traversal, Language: Go, Language: Java, Language: JavaScript/Node.js, Language: PHP, Language: Python (+5 more)

### Community 22 - "Prevent Cross-Site Scripting (XSS)"
Cohesion: 0.14
Nodes (13): Browser DOM Manipulation, Direct ResponseWriter Write, Django HttpResponse, Echo with Request Data, Flask Unsanitized Response, General Prevention Guidelines, Language: Go, Language: Java (+5 more)

### Community 23 - "General Best Practices for Avoiding Race Conditions"
Cohesion: 0.15
Nodes (11): General Best Practices for Avoiding Race Conditions, Hardcoded /tmp Path, Insecure Temporary File Creation, Insecure Temporary File Creation, Language: Go, Language: OCaml, Language: Python, Language-Specific Secure Alternatives (+3 more)

### Community 24 - "Prevent XML External Entity (XXE) Injection"
Cohesion: 0.17
Nodes (11): DocumentBuilderFactory - Disallow DOCTYPE Declaration, Language: C\#, Language: Go, Language: Java, Language: JavaScript, Language: Python, libxml2 - External Entities Enabled, libxmljs - noent Option Enabled (+3 more)

### Community 25 - "Code Best Practices"
Cohesion: 0.18
Nodes (10): Avoid Deprecated Libraries, Code Best Practices, Cookie Security Flags, File Handling - Always Close Files, Load Modules at Top Level, Network Requests Need Timeouts, Remove Debug Statements, Secure Temporary File Creation (+2 more)

### Community 26 - "terraform-gcp.md"
Cohesion: 0.18
Nodes (10): Cloud Run, Cloud Build, Dataproc, and Vertex AI, Cloud SQL, Google Cloud Storage (GCS), Google Compute Engine and Firewall, Google Kubernetes Engine (GKE), IAM, VPC, and Networking, KMS, Redis, BigQuery, and Pub/Sub, References (+2 more)

### Community 27 - "Categories"
Cohesion: 0.18
Nodes (10): Categories, Code Security Guidelines, Critical Impact, High Impact, How to Use This Skill, Infrastructure, Language-Specific Priority Rules, Medium/Low Impact (+2 more)

### Community 28 - "Prevent Cross-Site Request Forgery"
Cohesion: 0.20
Nodes (9): CSRF Disabled, CSRF Exempt Decorator, Language: Java / Spring, Language: JavaScript / Express, Language: Python / Django, Language: Ruby / Rails, Missing CSRF Middleware, Missing CSRF Protection (+1 more)

### Community 29 - "Secure Kubernetes Configurations"
Cohesion: 0.20
Nodes (9): Docker Socket Exposure, Host IPC Namespace, Host Network Namespace, Host PID Namespace, Privilege Escalation, Privileged Containers, Run as Non-Root, Secrets in Config Files (+1 more)

### Community 30 - "Secure Azure Terraform Configurations"
Cohesion: 0.20
Nodes (9): AKS Security, App Service Security, Database Security, IAM - Custom Roles, Key Vault Security, Public Network Access and Network Isolation, Secure Azure Terraform Configurations, Storage Account Security (+1 more)

### Community 31 - "Python"
Cohesion: 0.22
Nodes (8): Avoid Unnecessary Operations in Loops, Django - Access Foreign Keys Directly, JavaScript/TypeScript, Performance Best Practices, Python, React - Define Styled Components at Module Level, SQLAlchemy - Batch Database Operations, SQLAlchemy - Use count() Instead of len(all())

### Community 32 - "Prevent SQL Injection"
Cohesion: 0.22
Nodes (8): C# (SqlCommand), Go (database/sql), Java (JDBC), JavaScript/Node.js (pg), Key Prevention Rules, Prevent SQL Injection, Python (psycopg2), Ruby (pg gem)

### Community 33 - "How to Fetch Documentation"
Cohesion: 0.25
Nodes (7): Guidelines, How to Fetch Documentation, Step 1: Resolve the Library ID, Step 2: Select the Best Match, Step 3: Fetch the Documentation, Step 4: Use the Documentation, When to Use This Skill

### Community 34 - "Code Security"
Cohesion: 0.25
Nodes (7): 22.1 Secure GitHub Actions, 22. GitHub Actions Security, 23.1 Prevent Regular Expression DoS, 23. Regular Expression DoS, Abstract, Code Security, Table of Contents

### Community 35 - "Secure Docker Configurations"
Cohesion: 0.25
Nodes (7): Arbitrary Container Run (Python Docker SDK), Exposing Docker Socket, Missing Image Version, Privileged Mode (Docker Compose), Running as Root, Secure Docker Configurations, Using Latest Tag

### Community 36 - "Avoid Insecure Cryptography"
Cohesion: 0.25
Nodes (7): Avoid Insecure Cryptography, Best Practices, Go, Java, JavaScript, Python, Remediation Summary

### Community 37 - "Use Secure Transport"
Cohesion: 0.25
Nodes (7): Language: Go, Language: Java, Language: JavaScript/Node.js, Language: Python, References, Summary of CWEs, Use Secure Transport

### Community 38 - "Prevent Server-Side Request Forgery (SSRF)"
Cohesion: 0.25
Nodes (7): Language: Go, Language: Java, Language: JavaScript / Node.js, Language: PHP, Language: Python, Language: Ruby, Prevent Server-Side Request Forgery (SSRF)

### Community 39 - "Secure AWS Terraform Configurations"
Cohesion: 0.25
Nodes (7): Credentials, IAM Overly Permissive Policies, Key Management, Network Security, S3 Encryption, Secure AWS Terraform Configurations, Unencrypted Storage

### Community 40 - "How to Fetch Documentation"
Cohesion: 0.25
Nodes (7): Guidelines, How to Fetch Documentation, Step 1: Resolve the Library ID, Step 2: Select the Best Match, Step 3: Fetch the Documentation, Step 4: Use the Documentation, When to Use This Skill

### Community 41 - "Prevent Command Injection"
Cohesion: 0.29
Nodes (6): Language: Go, Language: Java, Language: JavaScript / Node.js, Language: Python, Language: Ruby, Prevent Command Injection

### Community 42 - "Secure GitHub Actions"
Cohesion: 0.29
Nodes (6): Key Security Risks, Pull Request Target Code Checkout (CWE-913), Run Shell Injection (CWE-78), Secure GitHub Actions, Third-Party Action Not Pinned to Commit SHA (CWE-1357), Workflow Run Target Code Checkout (CWE-913)

### Community 43 - "Ensure Memory Safety"
Cohesion: 0.29
Nodes (6): Buffer Overflow (CWE-119, CWE-120), Double Free (CWE-415), Ensure Memory Safety, Format String Vulnerabilities (CWE-134), Prevention Best Practices, Use After Free (CWE-416)

### Community 44 - "Prevent Regular Expression DoS (ReDoS)"
Cohesion: 0.40
Nodes (4): General Mitigation Strategies, Language: JavaScript / TypeScript, Language: Python, Prevent Regular Expression DoS (ReDoS)

### Community 45 - "plugin"
Cohesion: 0.40
Nodes (4): plugin, $schema, .opencode/plugins/graphify.js, opencode-supabase

### Community 46 - "code-injection.md"
Cohesion: 0.50
Nodes (3): Key Prevention Patterns, Prevent Code Injection, References

### Community 47 - "mcp.json"
Cohesion: 0.50
Nodes (3): context7, github, vercel

## Knowledge Gaps
- **321 isolated node(s):** `Abstract`, `Table of Contents`, `1.1 Prevent SQL Injection`, `2.1 Prevent Command Injection`, `3.1 Prevent Cross-Site Scripting (XSS)` (+316 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **42 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Code Security` connect `Code Security` to `10. Insecure Cryptography`, `11. Insecure Transport`, `12. Server-Side Request Forgery`, `13. JWT Authentication`, `14. Cross-Site Request Forgery`, `15. Prototype Pollution`, `16. Unsafe Functions`, `17. Terraform AWS Security`, `18. Terraform Azure Security`, `19. Terraform GCP Security`, `1. SQL Injection`, `20. Kubernetes Security`, `21. Docker Security`, `24. Race Conditions`, `25. Code Correctness`, `26. Best Practices`, `27. Performance`, `28. Maintainability`, `2. Command Injection`, `3. Cross-Site Scripting`, `4. XML External Entity`, `5. Path Traversal`, `6. Insecure Deserialization`, `7. Code Injection`, `8. Hardcoded Secrets`, `9. Memory Safety`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Why does `DesignSystemGenerator` connect `DesignSystemGenerator` to `design_system.py`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `Abstract`, `Table of Contents`, `1.1 Prevent SQL Injection` to the rest of the system?**
  _321 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `bash` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._
- **Should `design_system.py` be split into smaller, more focused modules?**
  _Cohesion score 0.07948717948717948 - nodes in this community are weakly interconnected._
- **Should `High Impact` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._
- **Should `ui-ux-pro-max` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._
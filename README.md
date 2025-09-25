# MEDVAULT - Medical Data Sovereignty Platform

## Overview

MEDVAULT is a blockchain-based **patient-controlled health record platform** with selective sharing, privacy-preserving access management, and transparent audit trails. It empowers patients to control access to their medical data while enabling trusted providers, researchers, and institutions to collaborate. This system aligns with **UN SDG 3: Good Health and Well-Being**.

## Features

* Patient self-sovereign health data registry
* Verified healthcare provider management
* Encrypted medical record storage references (e.g., IPFS)
* Fine-grained access permissions with expiry and conditions
* Emergency access protocols with auto-expiry and notifications
* Data sharing agreements with optional compensation
* Research participation with anonymity and withdrawal rights
* Comprehensive audit trails and privacy violation reporting
* Platform-level statistics and transparency

## Data Structures

* **patients** – Patient registry with personal, privacy, and consent info
* **healthcare-providers** – Provider registry with type, license, and reputation
* **medical-records** – Encrypted medical record references with metadata
* **access-permissions** – Granted permissions with levels, expiry, and conditions
* **access-log** – Record of all access events including emergencies
* **emergency-access** – Emergency overrides with expiry and notification flags
* **sharing-agreements** – Data sharing arrangements with terms and compensation
* **research-participation** – Research contributions with consent tracking
* **privacy-audits** – Audit logs for compliance and violations

## Core Constants

* **Provider Types**: Doctor, Hospital, Specialist, Lab, Pharmacy, Insurance, Researcher
* **Data Categories**: General, Diagnostic, Treatment, Medication, Lab, Imaging, Mental Health, Genetic
* **Permission Levels**: View, Update, Full, Emergency
* **Time**: 144 blocks/day, 4320 blocks/month, Emergency = 1 day

## Core Functions

### Registration

* `register-patient(...)` – Register as a patient with privacy preferences
* `register-provider(...)` – Register as a healthcare provider with license details

### Medical Records

* `add-medical-record(...)` – Add a new encrypted medical record reference

### Access Permissions

* `grant-access(...)` – Grant access permissions with scope and expiry
* `revoke-access(permission-id)` – Revoke existing permission

### Data Access

* `access-record(record-id, reason, is-emergency)` – Access a record with permission or emergency override

### Data Sharing

* `create-sharing-agreement(...)` – Create a data-sharing agreement with compensation and anonymization options

### Administration

* `verify-provider(provider)` – Verify a healthcare provider (owner only)
* `report-privacy-violation(details)` – Report privacy or data misuse

### Read-Only Queries

* `get-patient-info(patient)` – Get patient details
* `get-provider-info(provider)` – Get provider details
* `get-record-metadata(record-id)` – Get record metadata
* `get-patient-permissions(patient)` – Get patient’s granted permissions
* `get-platform-stats()` – Platform-wide statistics

## Error Codes

* `ERR-NOT-AUTHORIZED (300)` – Unauthorized action
* `ERR-INVALID-AMOUNT (301)` – Invalid value
* `ERR-PATIENT-NOT-FOUND (302)` – Patient not found
* `ERR-PROVIDER-NOT-FOUND (303)` – Provider not found
* `ERR-RECORD-NOT-FOUND (304)` – Record not found
* `ERR-ALREADY-REGISTERED (305)` – Already registered
* `ERR-INVALID-PERMISSION (306)` – Invalid permission request
* `ERR-ACCESS-DENIED (307)` – No permission to access data
* `ERR-INVALID-RESEARCHER (308)` – Researcher not authorized
* `ERR-DATA-EXPIRED (309)` – Data access expired

## Platform Metrics

* Total patients
* Total providers
* Total records created
* Total data shares
* Privacy violations reported

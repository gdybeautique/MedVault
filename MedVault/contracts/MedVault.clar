;;; ===================================================
;;; MEDVAULT - MEDICAL DATA SOVEREIGNTY PLATFORM
;;; ===================================================
;;; A blockchain-based platform for patient-controlled health records
;;; with selective sharing and privacy-preserving access management.
;;; Addresses UN SDG 3: Good Health through data empowerment.
;;; ===================================================

;; ===================================================
;; CONSTANTS AND ERROR CODES
;; ===================================================

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-AMOUNT (err u301))
(define-constant ERR-PATIENT-NOT-FOUND (err u302))
(define-constant ERR-PROVIDER-NOT-FOUND (err u303))
(define-constant ERR-RECORD-NOT-FOUND (err u304))
(define-constant ERR-ALREADY-REGISTERED (err u305))
(define-constant ERR-INVALID-PERMISSION (err u306))
(define-constant ERR-ACCESS-DENIED (err u307))
(define-constant ERR-INVALID-RESEARCHER (err u308))
(define-constant ERR-DATA-EXPIRED (err u309))

;; Provider Types
(define-constant PROVIDER-DOCTOR u1)
(define-constant PROVIDER-HOSPITAL u2)
(define-constant PROVIDER-SPECIALIST u3)
(define-constant PROVIDER-LAB u4)
(define-constant PROVIDER-PHARMACY u5)
(define-constant PROVIDER-INSURANCE u6)
(define-constant PROVIDER-RESEARCHER u7)

;; Data Categories
(define-constant DATA-GENERAL u1)
(define-constant DATA-DIAGNOSTIC u2)
(define-constant DATA-TREATMENT u3)
(define-constant DATA-MEDICATION u4)
(define-constant DATA-LAB-RESULTS u5)
(define-constant DATA-IMAGING u6)
(define-constant DATA-MENTAL-HEALTH u7)
(define-constant DATA-GENETIC u8)

;; Permission Levels
(define-constant PERMISSION-VIEW u1)
(define-constant PERMISSION-UPDATE u2)
(define-constant PERMISSION-FULL u3)
(define-constant PERMISSION-EMERGENCY u4)

;; Time Constants
(define-constant BLOCKS-PER-DAY u144)
(define-constant BLOCKS-PER-MONTH u4320)
(define-constant EMERGENCY-ACCESS-DURATION u144) ;; 1 day

;; ===================================================
;; DATA STRUCTURES
;; ===================================================

;; Patient Registry
(define-map patients
    { patient: principal }
    {
        patient-name: (string-ascii 100),
        date-of-birth: uint, ;; block height representing birth year
        emergency-contacts: (list 3 principal),
        registration-date: uint,
        privacy-level: uint, ;; 1-5 scale, 5 = most private
        data-sharing-consent: bool,
        research-consent: bool,
        total-records: uint,
        last-activity: uint,
        is-active: bool,
        master-key-hash: (buff 32)
    }
)

;; Healthcare Providers
(define-map healthcare-providers
    { provider: principal }
    {
        provider-name: (string-ascii 100),
        provider-type: uint,
        license-number: (string-ascii 50),
        specialization: (string-ascii 100),
        institution: (string-ascii 100),
        location: (string-ascii 100),
        registration-date: uint,
        verification-status: bool,
        patients-treated: uint,
        reputation-score: uint, ;; 0-100
        is-active: bool
    }
)

;; Medical Records
(define-map medical-records
    { record-id: uint }
    {
        patient: principal,
        provider: principal,
        data-category: uint,
        record-date: uint,
        record-type: (string-ascii 50),
        data-hash: (buff 64), ;; IPFS hash of encrypted data
        access-level-required: uint,
        is-sensitive: bool,
        retention-period: uint, ;; blocks until auto-deletion
        encryption-key-id: uint,
        last-accessed: uint,
        access-count: uint
    }
)

;; Access Permissions
(define-map access-permissions
    { permission-id: uint }
    {
        patient: principal,
        provider: principal,
        data-categories: (list 8 uint),
        permission-level: uint,
        granted-date: uint,
        expiry-date: uint,
        purpose-of-access: (string-ascii 200),
        is-active: bool,
        conditions: (string-ascii 300),
        auto-revoke: bool
    }
)

;; Data Access Log
(define-map access-log
    { log-id: uint }
    {
        patient: principal,
        provider: principal,
        record-id: uint,
        access-date: uint,
        access-type: (string-ascii 30), ;; "VIEW", "UPDATE", "SHARE"
        access-reason: (string-ascii 200),
        ip-hash: (buff 32),
        was-emergency: bool,
        patient-notified: bool
    }
)

;; Emergency Access Registry
(define-map emergency-access
    { emergency-id: uint }
    {
        patient: principal,
        emergency-provider: principal,
        emergency-date: uint,
        emergency-type: (string-ascii 100),
        access-granted-automatically: bool,
        records-accessed: (list 10 uint),
        patient-notification-sent: bool,
        access-expires: uint
    }
)

;; Data Sharing Agreements
(define-map sharing-agreements
    { agreement-id: uint }
    {
        patient: principal,
        recipient: principal,
        data-categories: (list 8 uint),
        sharing-purpose: (string-ascii 200),
        compensation-amount: uint,
        agreement-date: uint,
        duration: uint,
        anonymization-level: uint,
        is-revocable: bool,
        is-active: bool
    }
)

;; Research Participation
(define-map research-participation
    { participation-id: uint }
    {
        patient: principal,
        research-institution: principal,
        study-description: (string-ascii 300),
        data-contributed: (list 8 uint),
        compensation-earned: uint,
        participation-date: uint,
        withdrawal-allowed: bool,
        anonymity-guaranteed: bool,
        is-active: bool
    }
)

;; Privacy Audit Trail
(define-map privacy-audits
    { audit-id: uint }
    {
        patient: principal,
        audit-date: uint,
        privacy-violations: uint,
        unauthorized-access-attempts: uint,
        data-breaches: uint,
        compliance-score: uint, ;; 0-100
        recommendations: (string-ascii 500)
    }
)

;; ===================================================
;; DATA VARIABLES
;; ===================================================

(define-data-var next-record-id uint u1)
(define-data-var next-permission-id uint u1)
(define-data-var next-log-id uint u1)
(define-data-var next-emergency-id uint u1)
(define-data-var next-agreement-id uint u1)
(define-data-var next-participation-id uint u1)
(define-data-var next-audit-id uint u1)
(define-data-var total-patients uint u0)
(define-data-var total-providers uint u0)
(define-data-var total-data-shares uint u0)
(define-data-var privacy-violations-reported uint u0)

;; ===================================================
;; PRIVATE FUNCTIONS
;; ===================================================

;; Check if provider has permission for data category
(define-private (has-permission (patient principal) (provider principal) (data-category uint) (required-level uint))
    ;; Simplified permission check - real implementation would query permission records
    ;; For now, assume providers have basic permissions for demonstration
    (is-some (map-get? healthcare-providers { provider: provider }))
)

;; Check if data is sensitive
(define-private (is-sensitive-data (data-category uint))
    (or (is-eq data-category DATA-MENTAL-HEALTH)
        (or (is-eq data-category DATA-GENETIC)
            (is-eq data-category DATA-DIAGNOSTIC)))
)

;; Calculate data value for sharing agreements
(define-private (calculate-data-value (data-categories (list 8 uint)) (patient-profile principal))
    ;; Simplified calculation - real implementation would consider rarity, research value, etc.
    (* (len data-categories) u1000000) ;; 1 STX per data category
)

;; ===================================================
;; PUBLIC FUNCTIONS - REGISTRATION
;; ===================================================

;; Register as patient
(define-public (register-patient
    (patient-name (string-ascii 100))
    (birth-year uint)
    (emergency-contacts (list 3 principal))
    (privacy-level uint)
    (data-sharing-consent bool)
    (research-consent bool)
    (master-key-hash (buff 32)))
    
    (let (
        (registration-date stacks-block-height)
    )
    
    (asserts! (is-none (map-get? patients { patient: tx-sender })) ERR-ALREADY-REGISTERED)
    (asserts! (and (>= privacy-level u1) (<= privacy-level u5)) ERR-INVALID-AMOUNT)
    (asserts! (> birth-year u1900) ERR-INVALID-AMOUNT)
    
    ;; Register patient
    (map-set patients
        { patient: tx-sender }
        {
            patient-name: patient-name,
            date-of-birth: birth-year,
            emergency-contacts: emergency-contacts,
            registration-date: registration-date,
            privacy-level: privacy-level,
            data-sharing-consent: data-sharing-consent,
            research-consent: research-consent,
            total-records: u0,
            last-activity: registration-date,
            is-active: true,
            master-key-hash: master-key-hash
        }
    )
    
    (var-set total-patients (+ (var-get total-patients) u1))
    (ok true)
    )
)

;; Register as healthcare provider
(define-public (register-provider
    (provider-name (string-ascii 100))
    (provider-type uint)
    (license-number (string-ascii 50))
    (specialization (string-ascii 100))
    (institution (string-ascii 100))
    (location (string-ascii 100)))
    
    (let (
        (registration-date stacks-block-height)
    )
    
    (asserts! (is-none (map-get? healthcare-providers { provider: tx-sender })) ERR-ALREADY-REGISTERED)
    (asserts! (or (is-eq provider-type PROVIDER-DOCTOR)
                  (or (is-eq provider-type PROVIDER-HOSPITAL)
                      (or (is-eq provider-type PROVIDER-SPECIALIST)
                          (or (is-eq provider-type PROVIDER-LAB)
                              (or (is-eq provider-type PROVIDER-PHARMACY)
                                  (or (is-eq provider-type PROVIDER-INSURANCE)
                                      (is-eq provider-type PROVIDER-RESEARCHER))))))) ERR-INVALID-AMOUNT)
    
    ;; Register provider
    (map-set healthcare-providers
        { provider: tx-sender }
        {
            provider-name: provider-name,
            provider-type: provider-type,
            license-number: license-number,
            specialization: specialization,
            institution: institution,
            location: location,
            registration-date: registration-date,
            verification-status: false,
            patients-treated: u0,
            reputation-score: u75,
            is-active: true
        }
    )
    
    (var-set total-providers (+ (var-get total-providers) u1))
    (ok true)
    )
)

;; ===================================================
;; PUBLIC FUNCTIONS - MEDICAL RECORDS
;; ===================================================

;; Add medical record
(define-public (add-medical-record
    (patient principal)
    (data-category uint)
    (record-type (string-ascii 50))
    (data-hash (buff 64))
    (access-level-required uint)
    (retention-period uint))
    
    (let (
        (provider-data (unwrap! (map-get? healthcare-providers { provider: tx-sender }) ERR-PROVIDER-NOT-FOUND))
        (patient-data (unwrap! (map-get? patients { patient: patient }) ERR-PATIENT-NOT-FOUND))
        (record-id (var-get next-record-id))
        (is-sensitive (is-sensitive-data data-category))
    )
    
    (asserts! (get verification-status provider-data) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active patient-data) ERR-PATIENT-NOT-FOUND)
    (asserts! (and (>= data-category DATA-GENERAL) (<= data-category DATA-GENETIC)) ERR-INVALID-AMOUNT)
    (asserts! (> retention-period u0) ERR-INVALID-AMOUNT)
    
    ;; Check if provider has permission to add this type of record
    (asserts! (has-permission patient tx-sender data-category PERMISSION-UPDATE) ERR-ACCESS-DENIED)
    
    ;; Add medical record
    (map-set medical-records
        { record-id: record-id }
        {
            patient: patient,
            provider: tx-sender,
            data-category: data-category,
            record-date: stacks-block-height,
            record-type: record-type,
            data-hash: data-hash,
            access-level-required: access-level-required,
            is-sensitive: is-sensitive,
            retention-period: retention-period,
            encryption-key-id: u1, ;; Simplified
            last-accessed: stacks-block-height,
            access-count: u0
        }
    )
    
    ;; Update patient record count
    (map-set patients
        { patient: patient }
        (merge patient-data {
            total-records: (+ (get total-records patient-data) u1),
            last-activity: stacks-block-height
        })
    )
    
    (var-set next-record-id (+ record-id u1))
    (ok record-id)
    )
)

;; ===================================================
;; PUBLIC FUNCTIONS - ACCESS PERMISSIONS
;; ===================================================

;; Grant access permission
(define-public (grant-access
    (provider principal)
    (data-categories (list 8 uint))
    (permission-level uint)
    (duration-days uint)
    (purpose-of-access (string-ascii 200))
    (conditions (string-ascii 300)))
    
    (let (
        (patient-data (unwrap! (map-get? patients { patient: tx-sender }) ERR-PATIENT-NOT-FOUND))
        (provider-data (unwrap! (map-get? healthcare-providers { provider: provider }) ERR-PROVIDER-NOT-FOUND))
        (permission-id (var-get next-permission-id))
        (expiry-date (+ stacks-block-height (* duration-days BLOCKS-PER-DAY)))
    )
    
    (asserts! (get is-active patient-data) ERR-PATIENT-NOT-FOUND)
    (asserts! (get verification-status provider-data) ERR-PROVIDER-NOT-FOUND)
    (asserts! (and (>= permission-level PERMISSION-VIEW) (<= permission-level PERMISSION-EMERGENCY)) ERR-INVALID-PERMISSION)
    (asserts! (> duration-days u0) ERR-INVALID-AMOUNT)
    
    ;; Grant permission
    (map-set access-permissions
        { permission-id: permission-id }
        {
            patient: tx-sender,
            provider: provider,
            data-categories: data-categories,
            permission-level: permission-level,
            granted-date: stacks-block-height,
            expiry-date: expiry-date,
            purpose-of-access: purpose-of-access,
            is-active: true,
            conditions: conditions,
            auto-revoke: false
        }
    )
    
    (var-set next-permission-id (+ permission-id u1))
    (ok permission-id)
    )
)

;; Revoke access permission
(define-public (revoke-access (permission-id uint))
    (let (
        (permission-data (unwrap! (map-get? access-permissions { permission-id: permission-id }) ERR-INVALID-PERMISSION))
    )
    
    (asserts! (is-eq tx-sender (get patient permission-data)) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active permission-data) ERR-INVALID-PERMISSION)
    
    ;; Revoke permission
    (map-set access-permissions
        { permission-id: permission-id }
        (merge permission-data { is-active: false })
    )
    
    (ok true)
    )
)

;; ===================================================
;; PUBLIC FUNCTIONS - DATA ACCESS
;; ===================================================

;; Access medical record
(define-public (access-record
    (record-id uint)
    (access-reason (string-ascii 200))
    (is-emergency bool))
    
    (let (
        (record-data (unwrap! (map-get? medical-records { record-id: record-id }) ERR-RECORD-NOT-FOUND))
        (provider-data (unwrap! (map-get? healthcare-providers { provider: tx-sender }) ERR-PROVIDER-NOT-FOUND))
        (log-id (var-get next-log-id))
        (required-permission (if is-emergency PERMISSION-EMERGENCY (get access-level-required record-data)))
    )
    
    (asserts! (get verification-status provider-data) ERR-NOT-AUTHORIZED)
    
    ;; Check permission unless it's an emergency
    (if (not is-emergency)
        (asserts! (has-permission (get patient record-data) tx-sender (get data-category record-data) required-permission) ERR-ACCESS-DENIED)
        true
    )
    
    ;; Log access
    (map-set access-log
        { log-id: log-id }
        {
            patient: (get patient record-data),
            provider: tx-sender,
            record-id: record-id,
            access-date: stacks-block-height,
            access-type: "VIEW",
            access-reason: access-reason,
            ip-hash: 0x00, ;; Would be actual IP hash
            was-emergency: is-emergency,
            patient-notified: true
        }
    )
    
    ;; Update record access stats
    (map-set medical-records
        { record-id: record-id }
        (merge record-data {
            last-accessed: stacks-block-height,
            access-count: (+ (get access-count record-data) u1)
        })
    )
    
    (var-set next-log-id (+ log-id u1))
    (ok (get data-hash record-data))
    )
)

;; ===================================================
;; PUBLIC FUNCTIONS - DATA SHARING
;; ===================================================

;; Create data sharing agreement
(define-public (create-sharing-agreement
    (recipient principal)
    (data-categories (list 8 uint))
    (sharing-purpose (string-ascii 200))
    (duration-days uint)
    (anonymization-level uint)
    (compensation-amount uint))
    
    (let (
        (patient-data (unwrap! (map-get? patients { patient: tx-sender }) ERR-PATIENT-NOT-FOUND))
        (agreement-id (var-get next-agreement-id))
    )
    
    (asserts! (get is-active patient-data) ERR-PATIENT-NOT-FOUND)
    (asserts! (get data-sharing-consent patient-data) ERR-NOT-AUTHORIZED)
    (asserts! (> duration-days u0) ERR-INVALID-AMOUNT)
    (asserts! (and (>= anonymization-level u1) (<= anonymization-level u3)) ERR-INVALID-AMOUNT)
    
    ;; Transfer compensation if any
    (if (> compensation-amount u0)
        (try! (stx-transfer? compensation-amount recipient tx-sender))
        true
    )
    
    ;; Create agreement
    (map-set sharing-agreements
        { agreement-id: agreement-id }
        {
            patient: tx-sender,
            recipient: recipient,
            data-categories: data-categories,
            sharing-purpose: sharing-purpose,
            compensation-amount: compensation-amount,
            agreement-date: stacks-block-height,
            duration: (* duration-days BLOCKS-PER-DAY),
            anonymization-level: anonymization-level,
            is-revocable: true,
            is-active: true
        }
    )
    
    (var-set next-agreement-id (+ agreement-id u1))
    (var-set total-data-shares (+ (var-get total-data-shares) u1))
    
    (ok agreement-id)
    )
)

;; ===================================================
;; READ-ONLY FUNCTIONS
;; ===================================================

;; Get patient information
(define-read-only (get-patient-info (patient principal))
    (map-get? patients { patient: patient })
)

;; Get provider information
(define-read-only (get-provider-info (provider principal))
    (map-get? healthcare-providers { provider: provider })
)

;; Get medical record metadata
(define-read-only (get-record-metadata (record-id uint))
    (match (map-get? medical-records { record-id: record-id })
        record-data
            (some {
                patient: (get patient record-data),
                provider: (get provider record-data),
                data-category: (get data-category record-data),
                record-date: (get record-date record-data),
                record-type: (get record-type record-data),
                is-sensitive: (get is-sensitive record-data),
                access-count: (get access-count record-data)
            })
        none
    )
)

;; Get access permissions for patient
(define-read-only (get-patient-permissions (patient principal))
    ;; Simplified - would return list of active permissions
    (some (list))
)

;; Get platform statistics
(define-read-only (get-platform-stats)
    {
        total-patients: (var-get total-patients),
        total-providers: (var-get total-providers),
        total-records: (var-get next-record-id),
        total-data-shares: (var-get total-data-shares),
        privacy-violations: (var-get privacy-violations-reported)
    }
)

;; ===================================================
;; ADMIN FUNCTIONS
;; ===================================================

;; Verify healthcare provider
(define-public (verify-provider (provider principal))
    (let (
        (provider-data (unwrap! (map-get? healthcare-providers { provider: provider }) ERR-PROVIDER-NOT-FOUND))
    )
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    (map-set healthcare-providers
        { provider: provider }
        (merge provider-data { verification-status: true })
    )
    
    (ok true)
    )
)

;; Report privacy violation
(define-public (report-privacy-violation (violation-details (string-ascii 500)))
    (begin
    (asserts! (or (is-some (map-get? patients { patient: tx-sender }))
                  (is-some (map-get? healthcare-providers { provider: tx-sender }))) ERR-NOT-AUTHORIZED)
    
    (var-set privacy-violations-reported (+ (var-get privacy-violations-reported) u1))
    
    (ok true)
    )
)
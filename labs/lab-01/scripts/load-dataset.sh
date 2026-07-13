#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/common.sh"
require_command kubectl
[[ -f "${DATASET}" ]] || fail "Generate the dataset first"

log "Copying the validated release into PostgreSQL"
k -n "${DATA_NAMESPACE}" cp "${DATASET}" "${POSTGRES_POD}:/tmp/tickets.csv"
k -n "${DATA_NAMESPACE}" exec "${POSTGRES_POD}" -- psql -v ON_ERROR_STOP=1 -U supportops -d supportops <<'SQL'
CREATE SCHEMA IF NOT EXISTS helpdesk;
CREATE TABLE IF NOT EXISTS helpdesk.tickets (
  ticket_id text PRIMARY KEY,
  created_at timestamptz NOT NULL,
  channel text NOT NULL,
  language text NOT NULL,
  customer_tier text NOT NULL,
  product text NOT NULL,
  subject text NOT NULL,
  body text NOT NULL,
  category text NOT NULL,
  priority text NOT NULL CHECK (priority IN ('P1','P2','P3','P4')),
  escalated boolean NOT NULL,
  resolution_time_minutes integer NOT NULL CHECK (resolution_time_minutes > 0),
  agent_response text NOT NULL,
  satisfaction_score integer NOT NULL CHECK (satisfaction_score BETWEEN 1 AND 5),
  CONSTRAINT valid_language CHECK (language IN ('en','fr','es','de'))
);
TRUNCATE helpdesk.tickets;
\copy helpdesk.tickets FROM '/tmp/tickets.csv' WITH (FORMAT csv, HEADER true)
SQL

count="$(k -n "${DATA_NAMESPACE}" exec "${POSTGRES_POD}" -- \
  psql -At -U supportops -d supportops -c 'SELECT count(*) FROM helpdesk.tickets;')"
[[ "${count}" == "250" ]] || fail "Expected 250 PostgreSQL rows; observed ${count}"
log "PostgreSQL contains ${count} helpdesk tickets"

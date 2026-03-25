#!/usr/bin/env node
/**
 * stitch-proxy.mjs
 * LOCAL STDIO PROXY for the Google Stitch MCP server.
 *
 * Kiro connects to this process via stdio (see .kiro/settings/mcp.json).
 * This proxy forwards all MCP calls to https://stitch.googleapis.com/mcp
 * using Google Cloud Application Default Credentials (ADC).
 *
 * AUTHENTICATION
 * The real Stitch MCP requires OAuth 2 / ADC. API keys are not accepted.
 * Prerequisites:
 *   1. gcloud auth application-default login
 *   2. gcloud auth application-default set-quota-project northern-syntax-483410-v6
 *   3. npm install  (installs google-auth-library)
 *
 * VALIDATED
 * Auth scheme confirmed on 2026-03-25:
 *   - tools/list: public, no auth required
 *   - tools/call: requires ADC token + x-goog-user-project header
 *   - First successful tools/call: list_projects → {} (empty project list)
 *   - First screen generated: finance-dashboard-v0.1-2026-03-25.md
 *   - Project created: re-sap-ifrs16 (ID: 8885202212425441682)
 *
 * See design/stitch/DESIGN.md DQ-01 for history.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { GoogleAuth } from "google-auth-library";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const STITCH_MCP_URL = "https://stitch.googleapis.com/mcp";
const QUOTA_PROJECT = "northern-syntax-483410-v6";
const SCOPES = ["https://www.googleapis.com/auth/cloud-platform"];

// ---------------------------------------------------------------------------
// Google ADC auth client
// ---------------------------------------------------------------------------

const auth = new GoogleAuth({ scopes: SCOPES });

async function getToken() {
  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  if (!tokenResponse.token) {
    throw new Error(
      "ADC token unavailable. Run: gcloud auth application-default login"
    );
  }
  return tokenResponse.token;
}

// ---------------------------------------------------------------------------
// Forward an MCP JSON-RPC request to the real Stitch endpoint
// ---------------------------------------------------------------------------

async function forwardToStitch(method, params) {
  const token = await getToken();
  const response = await fetch(STITCH_MCP_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "x-goog-user-project": QUOTA_PROJECT,
    },
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method, params }),
  });
  const json = await response.json();
  if (json.error) {
    throw new Error(`Stitch MCP error: ${JSON.stringify(json.error)}`);
  }
  return json.result;
}

// ---------------------------------------------------------------------------
// MCP Server — forwards tools/list and tools/call to real Stitch
// ---------------------------------------------------------------------------

const server = new Server(
  { name: "stitch", version: "0.2.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return await forwardToStitch("tools/list", {});
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  return await forwardToStitch("tools/call", { name, arguments: args });
});

// ---------------------------------------------------------------------------
// Start proxy server
// ---------------------------------------------------------------------------

const transport = new StdioServerTransport();
await server.connect(transport);
console.error(
  "[stitch-proxy] ADC forwarding proxy started. Connecting to " + STITCH_MCP_URL
);

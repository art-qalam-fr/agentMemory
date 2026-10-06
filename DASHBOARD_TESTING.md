# Dashboard Testing Guide

## ✅ Test Data Created!

6 sample memories have been created in `~/Projects/agentMemory/mcp-data/agentMemory/`

## How to Test Dashboard

### Step 1: Open the Dashboard

1. Open VS Code
2. Press `Cmd+Shift+P` (Command Palette)
3. Type: "agentMemory: Open Memory Dashboard"
4. Press Enter

### Step 2: Verify Dashboard Shows Data

**Expected Results:**

📊 **Overview Cards:**
- Total Memories: 6
- Projects: 1
- Active Agents: 3 (Cline, KiloCode, RooCode)
- Tokens Written: ~500-600 (estimated from content length)
- Tokens Read: ~2K-3K (based on access counts)

📈 **Agent Activity Chart:**
- KiloCode: 3 writes
- Cline: 2 writes  
- RooCode: 1 write
- Bars show reads based on accessCount

🥧 **Memory Types Chart:**
- Architecture: 2
- Pattern: 1
- Feature: 1
- Bug: 1
- Decision: 1

📋 **Recent Activity Table:**
- Should show 6 entries
- Timestamps from last 4 days
- Agent names and keys visible

🏆 **Top Memories Table:**
- database-schema (8 accesses)
- oauth-implementation (5 accesses)
- api-rate-limiting (4 accesses)
- etc.

### Step 3: Test Refresh

1. Click the "🔄 Refresh" button in dashboard
2. Data should reload without errors

### Step 4: Check Developer Console (Optional)

1. Open Developer Tools: `Help → Toggle Developer Tools`
2. Check Console tab for logs:
   - `[Dashboard] Loaded 6 memories`
   - No errors

## Troubleshooting

### Issue: Dashboard still shows zeros

**Check 1:** Verify files were created
```bash
ls -la ~/Projects/agentMemory/mcp-data/agentMemory/
```
Should see 6 `.json` files

**Check 2:** Verify dashboard is reading correct path
Open DevTools Console, run:
```javascript
// Check what path dashboard is looking for
console.log(vscode.workspace.workspaceFolders[0].uri.fsPath);
```

**Check 3:** Check Extension Output
1. View → Output
2. Select "agentMemory" dropdown
3. Look for dashboard logs

### Issue: Dashboard crashes or shows errors

**Check Console for errors:**
- File read errors?
- JSON parse errors?
- Path issues?

**Solution:** Check file permissions on `./mcp-data/` directory

## Clean Up Test Data (Optional)

To remove test data:
```bash
rm -rf ~/Projects/agentMemory/mcp-data/agentMemory/
```

## Create More Test Data

Run the test script again:
```bash
node test-dashboard.js
```

Each run creates 6 new memories with new IDs.

## Next Steps

Once dashboard works with test data:
1. ✅ Verify all charts render
2. ✅ Verify tables populate
3. ✅ Test with real agent (KiloCode creating actual memories)
4. ✅ Verify dashboard updates when new memories are added

---

## Expected Dashboard Appearance

```
╔════════════════════════════════════════════════════════════╗
║  🧠 Memory Dashboard                      [🔄 Refresh]    ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        ║
║  │Total: 6 │ │Proj: 1  │ │Agents:3 │ │Tokens:  │        ║
║  │Memories │ │Projects │ │Active   │ │~500 / ~2K│       ║
║  └─────────┘ └─────────┘ └─────────┘ └─────────┘        ║
║                                                            ║
║  ┌──────────────────┐  ┌──────────────────┐             ║
║  │ Agent Activity   │  │ Memory Types     │             ║
║  │ [Bar Chart]      │  │ [Pie Chart]      │             ║
║  └──────────────────┘  └──────────────────┘             ║
║                                                            ║
║  ┌───────────────────────────────────────┐               ║
║  │ Recent Activity                        │               ║
║  │ • oauth-implementation (kilocode)      │               ║
║  │ • database-schema (kilocode)           │               ║
║  │ • ...                                  │               ║
║  └───────────────────────────────────────┘               ║
╚════════════════════════════════════════════════════════════╝
```

The dashboard should now be fully functional! 🎉

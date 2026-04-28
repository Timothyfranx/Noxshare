const fs = require('fs');

/**
 * NoxSplitter iApp
 * This code runs inside an iExec TEE (Intel TDX).
 * It calculates private dividends based on revenue and encrypted share handles.
 */
async function main() {
    try {
        // 1. Read input revenue (Passed as a requester secret for security)
        const revenueStr = process.env.IEXEC_REQUESTER_SECRET_1;
        if (!revenueStr) {
            console.error("TEE Error: Revenue not provided in IEXEC_REQUESTER_SECRET_1");
            process.exit(1);
        }
        const revenue = parseFloat(revenueStr);
        if (isNaN(revenue)) {
            console.error(`TEE Error: Invalid revenue format: ${revenueStr}`);
            process.exit(1);
        }
        
        // 2. Read investor shares from protected data
        const sharesPath = '/iexec_in/shares.json';
        if (!fs.existsSync(sharesPath)) {
            console.error("TEE Error: Protected shares data not found at", sharesPath);
            // FAIL LOUDLY - No mock data fallback allowed
            process.exit(1);
        }

        const data = fs.readFileSync(sharesPath);
        const shares = JSON.parse(data);

        console.log(`TEE: Processing revenue of $${revenue}`);

        // 3. Calculate dividends
        const results = {};
        for (const [investor, percentage] of Object.entries(shares)) {
            results[investor] = revenue * percentage;
            console.log(`TEE: Calculated dividend for ${investor}`);
        }

        // 4. Output results to the iExec output folder
        const outputPath = '/iexec_out/result.json';
        fs.writeFileSync(outputPath, JSON.stringify(results));
        
        // Create deterministic response file required by iExec
        const computedFile = JSON.stringify({ "deterministic-output-path": outputPath });
        fs.writeFileSync('/iexec_out/computed.json', computedFile);

        console.log("TEE: Calculation complete. Results saved.");

    } catch (error) {
        console.error("TEE Error:", error);
        process.exit(1);
    }
}

main();

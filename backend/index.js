const express = require('express');
const cors = require('cors');
const fs = require('fs');
const { exec } = require('child_process');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const compilerName = process.platform === 'win32' ? 'compiler.exe' : 'compiler';
const COMPILER_CMD = path.join(__dirname, '..', compilerName);

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Compiler backend running on port ${PORT}`);
});

app.post('/api/compile', (req, res) => {
    const { code } = req.body;

    if (!code) {
        return res.status(400).json({ error: "No code provided" });
    }

    const inputPath = path.join(__dirname, 'input.txt');

    // 1. Write the incoming React code to your existing input.txt file
    fs.writeFile(inputPath, code, (err) => {
        if (err) {
            console.error("Failed to write input file:", err);
            return res.status(500).json({ error: "Server file write error" });
        }

        // 2. Execute the compiler, feeding it the input.txt file
        const command = `"${COMPILER_CMD}" < "${inputPath}"`;
        
        exec(command, (error, stdout, stderr) => {
            // Even if there's a compilation error, we want to send the output back 
            // so the user can see their syntax/semantic errors!
            
            // 3. Parse the giant stdout string into neat sections for the frontend
            const parsedOutput = parseCompilerOutput(stdout);

            // 4. Send the JSON response back to React
            res.json({
                success: true,
                rawOutput: stdout,
                ...parsedOutput
            });
        });
    });
});

// A helper function to slice up your beautiful C printf formatting
// The 6-Phase Bulletproof Parser
// The Clean-Marker Parser
// The 7-Phase Clean-Marker Parser
function parseCompilerOutput(output) {
    const lexerRaw = output.split('<PHASE_LEXER>')[1]?.split('<PHASE_AST>')[0];
    const astRaw = output.split('<PHASE_AST>')[1]?.split('<PHASE_SEMANTIC>')[0];
    const semanticRaw = output.split('<PHASE_SEMANTIC>')[1]?.split('<PHASE_SYMTAB>')[0];
    const symtabRaw = output.split('<PHASE_SYMTAB>')[1]?.split('<PHASE_TAC>')[0];
    const tacRaw = output.split('<PHASE_TAC>')[1]?.split('<PHASE_OPT_TAC>')[0];
    const optTacRaw = output.split('<PHASE_OPT_TAC>')[1]?.split('<PHASE_RISCV>')[0]; // NEW!
    const riscvRaw = output.split('<PHASE_RISCV>')[1];

    return {
        lexer: lexerRaw ? lexerRaw.trim() : "No Lexer Output",
        ast: astRaw ? astRaw.trim() : "No AST Output",
        semantic: semanticRaw ? semanticRaw.trim() : "No Semantic Output",
        symtab: symtabRaw ? symtabRaw.trim() : "No Symbol Table Output",
        tac: tacRaw ? tacRaw.trim() : "No TAC Output",
        opttac: optTacRaw ? optTacRaw.trim() : "No Optimized TAC Output", // NEW!
        riscv: riscvRaw ? riscvRaw.trim() : "No Target Code Output"
    };
}

app.get("/api/compile", (req, res) => {
    res.send("Hello");
})
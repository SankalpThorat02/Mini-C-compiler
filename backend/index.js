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

    fs.writeFile(inputPath, code, (err) => {
        if (err) {
            console.error("Failed to write input file:", err);
            return res.status(500).json({ error: "Server file write error" });
        }

        const command = `"${COMPILER_CMD}" < "${inputPath}"`;
        
        exec(command, (error, stdout, stderr) => {
            const parsedOutput = parseCompilerOutput(stdout);

            res.json({
                success: true,
                rawOutput: stdout,
                ...parsedOutput
            });
        });
    });
});

function parseCompilerOutput(output) {
    const lexerRaw = output.split('<PHASE_LEXER>')[1]?.split('<PHASE_AST>')[0];
    const astRaw = output.split('<PHASE_AST>')[1]?.split('<PHASE_SEMANTIC>')[0];
    const semanticRaw = output.split('<PHASE_SEMANTIC>')[1]?.split('<PHASE_SYMTAB>')[0];
    const symtabRaw = output.split('<PHASE_SYMTAB>')[1]?.split('<PHASE_TAC>')[0];
    const tacRaw = output.split('<PHASE_TAC>')[1]?.split('<PHASE_OPT_TAC>')[0];
    const optTacRaw = output.split('<PHASE_OPT_TAC>')[1]?.split('<PHASE_RISCV>')[0]; 
    const riscvRaw = output.split('<PHASE_RISCV>')[1];

    return {
        lexer: lexerRaw ? lexerRaw.trim() : "No Lexer Output",
        ast: astRaw ? astRaw.trim() : "No AST Output",
        semantic: semanticRaw ? semanticRaw.trim() : "No Semantic Output",
        symtab: symtabRaw ? symtabRaw.trim() : "No Symbol Table Output",
        tac: tacRaw ? tacRaw.trim() : "No TAC Output",
        opttac: optTacRaw ? optTacRaw.trim() : "No Optimized TAC Output", 
        riscv: riscvRaw ? riscvRaw.trim() : "No Target Code Output"
    };
}

app.get("/api/compile", (req, res) => {
    res.send("Hello");
})
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
function parseCompilerOutput(output) {
    // This looks for your specific header banners to split the text
    const lexerStart = output.indexOf("LEXICAL ANALYSIS PHASE");
    const astStart = output.indexOf("SEMANTIC ANALYSIS"); // Using this as the end of AST for now
    const tacStart = output.indexOf("Three Address Code"); // You might need to add a banner for this in C!
    const targetStart = output.indexOf(".text:");

    return {
        lexer: extractSection(output, lexerStart, astStart),
        ast: extractSection(output, astStart, tacStart), 
        tac: extractSection(output, tacStart, targetStart),
        riscv: targetStart !== -1 ? output.substring(targetStart) : "No target code generated."
    };
}

function extractSection(text, start, end) {
    if (start === -1) return "Section not found";
    if (end === -1) return text.substring(start);
    return text.substring(start, end);
}


app.get("/api/compile", (req, res) => {
    res.send("Hello");
})
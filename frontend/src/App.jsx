import { useState } from 'react';
import Editor from '@monaco-editor/react';
import axios from 'axios';
import './App.css';

function App() {
  // Default code for the editor
  const [code, setCode] = useState('int count;\ncount = 0;\n\nfor(count = 0; count < 5; count++) {\n    // Write your miniC code here\n}\n');
  
  // State to hold the output from your Express server
  const [output, setOutput] = useState({ lexer: '', ast: '', tac: '', riscv: '' });
  
  // UI State
  const [activeTab, setActiveTab] = useState('riscv');
  const [isCompiling, setIsCompiling] = useState(false);

  const handleCompile = async () => {
    setIsCompiling(true);
    try {
      // Hit your local Express backend
      const res = await axios.post('http://localhost:5000/api/compile', { code });
      
      setOutput({
        lexer: res.data.lexer || 'No Lexer Output Generated',
        ast: res.data.ast || 'No AST Generated',
        tac: res.data.tac || 'No TAC Generated',
        riscv: res.data.riscv || 'No Target Code Generated'
      });
      
    } catch (err) {
      setOutput({ 
        ...output, 
        lexer: 'Failed to connect to backend server. Make sure your Express server is running on port 5000!' 
      });
    }
    setIsCompiling(false);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      
      {/* 1. TOP NAVBAR */}
      <header style={{ padding: '15px 25px', backgroundColor: '#252526', borderBottom: '1px solid #333', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ color: '#007acc' }}>MiniC Compiler</h2>
        <button 
          onClick={handleCompile} 
          disabled={isCompiling}
          style={{ 
            padding: '10px 24px', 
            cursor: isCompiling ? 'not-allowed' : 'pointer', 
            backgroundColor: isCompiling ? '#555' : '#007acc', 
            color: 'white', 
            border: 'none', 
            borderRadius: '4px', 
            fontWeight: 'bold',
            transition: '0.2s'
          }}
        >
          {isCompiling ? 'Compiling...' : 'Run Code'}
        </button>
      </header>

      {/* 2. MAIN SPLIT SCREEN */}
      <div style={{ display: 'flex', flex: 1, height: 'calc(100vh - 65px)' }}>
        
        {/* LEFT: Code Editor */}
        <div style={{ flex: 1, borderRight: '1px solid #333' }}>
          <Editor
            height="100%"
            theme="vs-dark"
            defaultLanguage="c"
            value={code}
            onChange={(value) => setCode(value)}
            options={{ 
              minimap: { enabled: false }, 
              fontSize: 16,
              padding: { top: 20 }
            }}
          />
        </div>

        {/* RIGHT: Output Terminal */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', backgroundColor: '#1e1e1e' }}>
          
          {/* Output Tabs */}
          <div style={{ display: 'flex', backgroundColor: '#252526' }}>
            {['lexer', 'ast', 'tac', 'riscv'].map(tab => (
              <button 
                key={tab}
                onClick={() => setActiveTab(tab)}
                style={{
                  flex: 1,
                  padding: '12px 0',
                  background: activeTab === tab ? '#1e1e1e' : 'transparent',
                  color: activeTab === tab ? '#007acc' : '#888',
                  border: 'none',
                  borderTop: activeTab === tab ? '2px solid #007acc' : '2px solid transparent',
                  cursor: 'pointer',
                  textTransform: 'uppercase',
                  fontWeight: 'bold',
                  letterSpacing: '1px'
                }}
              >
                {tab.toUpperCase()}
              </button>
            ))}
          </div>

          {/* Terminal Screen */}
          <div style={{ flex: 1, padding: '20px', overflowY: 'auto' }}>
            <pre style={{ 
              margin: 0, 
              whiteSpace: 'pre-wrap', 
              fontFamily: "'Courier New', Courier, monospace", 
              color: '#d4d4d4',
              fontSize: '14px',
              lineHeight: '1.5'
            }}>
              {output[activeTab]}
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
import { useState } from 'react';
import Editor from '@monaco-editor/react';
import axios from 'axios';
import Tree from 'react-d3-tree';
import Split from 'react-split';
import './App.css';

const parseASTToJSON = (rawText) => {
  if (!rawText || rawText.includes("No AST Output")) return null;

  const lines = rawText.trim().split('\n');
  if (lines.length === 0) return null;

  const root = { name: lines[0].trim(), children: [] };
  const stack = [{ node: root, indent: 0 }];

  for (let i = 1; i < lines.length; i++) {
    const line = lines[i];
    if (line.trim() === '') continue;

    const indent = line.search(/\S/); 
    const name = line.trim();
    const newNode = { name, children: [] };

    while (stack.length > 0 && stack[stack.length - 1].indent >= indent) {
      stack.pop();
    }

    if (stack.length > 0) {
      stack[stack.length - 1].node.children.push(newNode);
    }
    stack.push({ node: newNode, indent });
  }

  const cleanEmptyChildren = (node) => {
    if (node.children.length === 0) {
      delete node.children;
    } else {
      node.children.forEach(cleanEmptyChildren);
    }
  };
  cleanEmptyChildren(root);

  return root;
};

function App() {
  const [code, setCode] = useState('// Welcome to the MiniC Studio\n\nint limit;\nlimit = 5;\n\nint countdown;\n\nfor (countdown = limit; countdown > 0; countdown--) {\n    int a;\n    a = countdown;\n}\n');
  const [output, setOutput] = useState({ lexer: '', ast: '', semantic: '', symtab: '', tac: '', opttac: '', riscv: '' });
  const [activeTab, setActiveTab] = useState('riscv');
  const [isCompiling, setIsCompiling] = useState(false);

  const handleEditorWillMount = (monaco) => {
    monaco.editor.defineTheme('minic-dark', {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: 'keyword', foreground: '#ff7b72', fontStyle: 'bold' },
        { token: 'type', foreground: '#79c0ff' },
        { token: 'identifier', foreground: '#c9d1d9' },
        { token: 'string', foreground: '#a5d6ff' },
        { token: 'number', foreground: '#7ee787' },
        { token: 'comment', foreground: '#8b949e', fontStyle: 'italic' },
        { token: 'operator', foreground: '#d2a8ff' }
      ],
      colors: {
        'editor.background': '#00000000',
        'editor.foreground': '#c9d1d9',
        'editorLineNumber.foreground': '#484f58',
        'editorLineNumber.activeForeground': '#c9d1d9',
        'editorCursor.foreground': '#58a6ff',
        'editor.selectionBackground': '#1f6feb40',
        'editor.lineHighlightBackground': '#161b2250',
        'editorIndentGuide.background': '#21262d',
        'editorIndentGuide.activeBackground': '#30363d'
      }
    });
  };

  const handleCompile = async () => {
    setIsCompiling(true);
    try {
      const res = await axios.post('http://localhost:5000/api/compile', { code });
      setOutput({
        lexer: res.data.lexer || 'No Lexer Output',
        ast: res.data.ast || 'No AST Output',
        semantic: res.data.semantic || 'No Semantic Output',
        symtab: res.data.symtab || 'No Symbol Table Generated',
        tac: res.data.tac || 'No TAC Generated',
        opttac: res.data.opttac || 'No Optimized TAC Generated',
        riscv: res.data.riscv || 'No Target Code Generated'
      });
    } catch (err) {
      setOutput({ ...output, lexer: '⚠️ Connection Error: Is your Express server running?' });
    }
    setIsCompiling(false);
  };

  const getTabColor = (tabId) => {
    switch(tabId) {
      case 'lexer': return '#ffa657';     
      case 'ast': return '#7ee787';       
      case 'semantic': return '#79c0ff';  
      case 'symtab': return '#ff79c6';    
      case 'tac': return '#d2a8ff';       
      case 'opttac': return '#ff7b72';    
      case 'riscv': return '#a5d6ff';     
      default: return '#c9d1d9';          
    }
  };

  const astData = parseASTToJSON(output.ast);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', backgroundColor: '#0d1117', color: '#c9d1d9', fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif' }}>
      
      <header style={{ padding: '12px 24px', backgroundColor: '#161b22', borderBottom: '1px solid #30363d', display: 'flex', justifyContent: 'space-between', alignItems: 'center', boxShadow: '0 4px 12px rgba(0,0,0,0.5)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#ff5f56' }}></div>
          <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#ffbd2e' }}></div>
          <div style={{ width: '12px', height: '12px', borderRadius: '50%', backgroundColor: '#27c93f' }}></div>
          <h2 style={{ marginLeft: '15px', fontSize: '1.2rem', fontWeight: '600', color: '#f0f6fc', letterSpacing: '0.5px' }}>
            MiniC Studio
          </h2>
        </div>
        
        <button 
          onClick={handleCompile} 
          disabled={isCompiling}
          style={{ padding: '8px 20px', cursor: isCompiling ? 'not-allowed' : 'pointer', backgroundColor: isCompiling ? '#238636' : '#2ea043', color: '#ffffff', border: '1px solid rgba(240, 246, 252, 0.1)', borderRadius: '6px', fontWeight: '600', fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', transition: 'all 0.2s ease', boxShadow: isCompiling ? 'none' : '0 0 10px rgba(46, 160, 67, 0.4)' }}
        >
          {isCompiling ? '⚙️ Compiling...' : '▶ Run Code'}
        </button>
      </header>

      <Split 
        sizes={[50, 50]} minSize={300} gutterSize={4} gutterAlign="center" 
        direction="horizontal" style={{ display: 'flex', flex: 1, overflow: 'hidden' }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', backgroundColor: '#0d1117', height: '100%' }}>
          <div style={{ padding: '8px 16px', backgroundColor: '#161b22', fontSize: '12px', color: '#8b949e', borderBottom: '1px solid #30363d', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: '600' }}>
            source.c
          </div>
          <div style={{ flex: 1, padding: '20px 0', overflow: 'hidden', backgroundColor: '#0d1117', backgroundImage: 'radial-gradient(circle at bottom left, rgba(46, 160, 67, 0.05), transparent 40%)' }}>
            <Editor
              height="100%" defaultLanguage="c" theme="minic-dark" beforeMount={handleEditorWillMount}
              value={code} onChange={(value) => setCode(value)}
              options={{ minimap: { enabled: false }, fontSize: 15, fontFamily: "'Fira Code', 'JetBrains Mono', Consolas, monospace", scrollBeyondLastLine: false, smoothScrolling: true, cursorBlinking: "smooth", borders: false, padding: { top: 10, left: 10 }, automaticLayout: true }}
            />
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', backgroundColor: '#0a0c10', height: '100%' }}>
          
          <div style={{ display: 'flex', backgroundColor: '#161b22', padding: '10px 10px 0 10px', borderBottom: '1px solid #30363d', gap: '4px', flexWrap: 'wrap' }}>
            {[
              { id: 'lexer', label: 'Lexer' },
              { id: 'ast', label: 'AST' },
              { id: 'semantic', label: 'Semantic Analysis' },
              { id: 'symtab', label: 'Symbol Table' },
              { id: 'tac', label: 'Raw TAC' },
              { id: 'opttac', label: 'Optimized TAC' },
              { id: 'riscv', label: 'RISC-V' }
            ].map(tab => (
              <button 
                key={tab.id} onClick={() => setActiveTab(tab.id)}
                style={{
                  padding: '10px 18px',
                  backgroundColor: activeTab === tab.id ? '#0a0c10' : 'transparent',
                  color: activeTab === tab.id ? '#58a6ff' : '#8b949e',
                  border: '1px solid',
                  borderColor: activeTab === tab.id ? '#30363d #30363d transparent #30363d' : 'transparent',
                  borderTopLeftRadius: '6px', borderTopRightRadius: '6px', borderBottom: 'none',
                  cursor: 'pointer', fontSize: '14px', fontWeight: activeTab === tab.id ? '600' : '500',
                  letterSpacing: '0.3px', transition: 'all 0.2s', transform: activeTab === tab.id ? 'translateY(1px)' : 'none',
                  marginBottom: '-1px'
                }}
              >
                {tab.label}
              </button>
            ))}
          </div>

          <div style={{ 
            flex: 1, 
            padding: activeTab === 'ast' ? '0' : '24px', 
            overflowY: activeTab === 'ast' ? 'hidden' : 'auto', 
            backgroundColor: 'transparent',
            backgroundImage: 'radial-gradient(circle at top right, rgba(88, 166, 255, 0.05), transparent 50%)',
            position: 'relative'
          }}>
            {!output[activeTab] ? (
              <div style={{ color: '#484f58', fontStyle: 'italic', marginTop: '20px', padding: '24px' }}>Run your code to see output...</div>
            ) : activeTab === 'ast' && astData ? (
              
              <div style={{ width: '100%', height: '100%' }}>
                <Tree 
                  data={astData} 
                  orientation="vertical"
                  pathFunc="diagonal" 
                  translate={{ x: 300, y: 50 }} 
                  scale={0.8} 
                  nodeSize={{ x: 200, y: 80 }}
                  separation={{ siblings: 1, nonSiblings: 1.2 }}
                  zoomable={true} 
                  panable={true}
                  renderCustomNodeElement={({ nodeDatum }) => (
                    <g>
                      <foreignObject x="-90" y="-24" width="180" height="48">
                        <div style={{
                          width: '100%', height: '100%',
                          backgroundColor: '#ffffff',
                          border: '1px solid #d0d7de',
                          borderLeft: '5px solid #33ff00',
                          borderRadius: '6px',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          color: '#24292f', 
                          fontFamily: "'Fira Code', 'JetBrains Mono', Consolas, monospace",
                          fontSize: '14px', fontWeight: '600', letterSpacing: '0.5px',
                          boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                          boxSizing: 'border-box', padding: '0 10px',
                          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'
                        }}>
                          {nodeDatum.name}
                        </div>
                      </foreignObject>
                    </g>
                  )}
                />
              </div>

            ) : (
              <pre style={{ margin: 0, whiteSpace: 'pre-wrap', fontFamily: "'Fira Code', 'JetBrains Mono', Consolas, monospace", color: getTabColor(activeTab), fontSize: '14px', lineHeight: '1.6', textShadow: activeTab === 'riscv' ? '0 0 2px rgba(165, 214, 255, 0.2)' : 'none' }}>
                {output[activeTab]}
              </pre>
            )}
          </div>
        </div>
      </Split>
    </div>
  );
}

export default App;
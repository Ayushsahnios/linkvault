import { useState } from 'react'
import axios from 'axios'
 
const API = 'http://localhost:3000'
 
export default function App() {
  const [url, setUrl] = useState('')
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)
  const [copied, setCopied] = useState(false)
 
  const handleShorten = async () => {
  console.log('button clicked', url)
  if (!url) return
  setLoading(true)
  setError(null)
  setResult(null)
  try {
    console.log('making request...')
    const res = await axios.post(`${API}/shorten`, { url })
    console.log('response:', res.data)
    setResult(res.data)
  } catch (err) {
    console.log('error:', err)
    setError(err.response?.data?.error || 'Something went wrong')
  } finally {
    setLoading(false)
  }
}
 
  const handleCopy = () => {
    navigator.clipboard.writeText(result.shortUrl)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }
 
  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <div style={styles.header}>
          <h1 style={styles.title}>LinkVault</h1>
          <p style={styles.subtitle}>Paste a long URL and get a short one</p>
        </div>
        <div style={styles.inputRow}>
          <input
            style={styles.input}
            type="text"
            placeholder="https://your-very-long-url.com/goes/here"
            value={url}
            onChange={e => setUrl(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleShorten()}
          />
<button
  style={styles.button}
  onClick={handleShorten}
>
  {loading ? 'Shortening...' : 'Shorten'}
</button>
        </div>
        {error && (
          <div style={styles.error}>{error}</div>
        )}
        {result && (
          <div style={styles.result}>
            <p style={styles.resultLabel}>Your short link</p>
            <div style={styles.resultRow}>
              <a
                href={result.shortUrl}
                target="_blank"
                rel="noreferrer"
                style={styles.link}
              >
                {result.shortUrl}
              </a>
              <button style={styles.copyBtn} onClick={handleCopy}>
                {copied ? 'Copied!' : 'Copy'}
              </button>
            </div>
            <p style={styles.original}>Original: {result.originalUrl}</p>
          </div>
        )}
      </div>
    </div>
  )
}
 
const styles = {
  page: {
    minHeight: '100vh',
    background: '#f5f5f3',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
    padding: '20px',
  },
  card: {
    background: '#fff',
    borderRadius: '12px',
    border: '1px solid #e0ddd6',
    padding: '40px',
    width: '100%',
    maxWidth: '560px',
  },
  header: {
    marginBottom: '28px',
  },
  title: {
    fontSize: '24px',
    fontWeight: '600',
    margin: '0 0 6px',
    color: '#1a1a18',
  },
  subtitle: {
    fontSize: '14px',
    color: '#888',
    margin: 0,
  },
  inputRow: {
    display: 'flex',
    gap: '10px',
  },
  input: {
    flex: 1,
    padding: '10px 14px',
    fontSize: '14px',
    border: '1px solid #ddd',
    borderRadius: '8px',
    outline: 'none',
    color: '#1a1a18',
  },
  button: {
    padding: '10px 20px',
    fontSize: '14px',
    fontWeight: '500',
    background: '#534AB7',
    color: '#fff',
    border: 'none',
    borderRadius: '8px',
    cursor: 'pointer',
  },
  error: {
    marginTop: '14px',
    padding: '10px 14px',
    background: '#FAECE7',
    color: '#993C1D',
    borderRadius: '8px',
    fontSize: '14px',
  },
  result: {
    marginTop: '20px',
    padding: '16px',
    background: '#f5f5f3',
    borderRadius: '8px',
  },
  resultLabel: {
    fontSize: '11px',
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    color: '#888',
    margin: '0 0 8px',
  },
  resultRow: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
  },
  link: {
    fontSize: '15px',
    fontWeight: '500',
    color: '#534AB7',
    flex: 1,
  },
  copyBtn: {
    padding: '6px 14px',
    fontSize: '13px',
    background: '#fff',
    border: '1px solid #ddd',
    borderRadius: '6px',
    cursor: 'pointer',
    color: '#444',
  },
  original: {
    fontSize: '12px',
    color: '#aaa',
    margin: '8px 0 0',
    wordBreak: 'break-all',
  },
}
 
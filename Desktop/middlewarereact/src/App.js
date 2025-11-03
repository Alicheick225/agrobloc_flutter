import './styles/App.css';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { useState, useEffect } from 'react';


import Home from './components/Home/Home';
import Bibliotheque from './components/bibliothèque/bibliotheque';
import Livre from './components/Livre/Livre';
import Login from './components/Auth/Login';
import Signup from './components/Auth/Signup';


function App() {
	const [token, setToken] = useState(localStorage.getItem('authToken'));

	// Mettre à jour l'état lorsque le token change
	const handleLogin = (newToken) => {
	  localStorage.setItem('authToken', newToken);
	  setToken(newToken);
	};
  
	const handleLogout = () => {
	  localStorage.removeItem('authToken');
	  setToken(null);
	};
  
	useEffect(() => {
	  const savedToken = localStorage.getItem('authToken');
	  setToken(savedToken);
	}, []);
  return (
    <Router>
      <div className="App">
        <header className="navbar">
          <div className="navbar-brand">Bibliothèque en Ligne</div>
          <ul className="navbar-menu">
            <li><Link to="/">Accueil</Link></li>
            <li><Link to="/bibliotheque">Bibliothèque</Link></li>
            <li><Link to="/livre">Nouveau doc</Link></li>
            {
              !localStorage.getItem('authToken') && <> <li><Link to="/login">Connexion</Link></li> <li><Link to="/signup">Inscription</Link></li> </>
            }
            {
              localStorage.getItem('authToken') && <> <li><Link to="/logout" onClick={handleLogout}>Deconnexion</Link></li> </>
            }
            
          </ul>
        </header>

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/bibliotheque" element={<Bibliotheque />} />
            <Route path="/livre" element={<Livre />} />
            <Route path="/login" element={<Login onLogin={handleLogin} />} />
            <Route path="/signup" element={<Signup />} />
            <Route path="/logout"/>
          </Routes>
        </main>

        <footer className="footer">
          <p>&copy; 2024 Bibliothèque en Ligne. Tous droits réservés.</p>
          <ul className="footer-menu">
            <li><Link to="/privacy">Politique de confidentialité</Link></li>
            <li><Link to="/terms">Conditions d'utilisation</Link></li>
          </ul>
        </footer>
      </div>
    </Router>
  );
}

export default App;

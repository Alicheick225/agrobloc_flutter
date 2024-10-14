import axios from "axios";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

function Signup() {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const navigate = useNavigate();

    const handleChange = (e) => {
        const { name, value } = e.target;

        if (name === 'name') {
            setName(value);
        }
        if (name === 'email') {
            setEmail(value);
        }
        if (name === 'password') {
            setPassword(value);
        }
        if (name === 'confirmPassword') {
            setConfirmPassword(value);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Vérifier que le mot de passe et la confirmation correspondent
        if (password !== confirmPassword) {
            alert("Les mots de passe ne correspondent pas !");
            return;
        }

        // Envoyer la requête au backend
        try {
            const response = await axios.post(
                'http://192.168.252.45:3000/auth/inscription',
                {
                    nom: name,
                    email: email,
                    motdepasse: password,
                    confirmMotdepasse: confirmPassword
                },
                {
                    headers: {
                        'Content-Type': 'application/json',
                    }
                }
            );

            if (response.status === 200) {
                navigate('/');
            }
        } catch (err) {
            console.error("Erreur serveur :", err.response?.data || err.message);
        }
    };

    return (
        <div>
            <h1>Inscription</h1>
            <form onSubmit={handleSubmit}>
                <label>Nom :</label>
                <input type="text" name="name" value={name} onChange={handleChange} required />

                <label>Email :</label>
                <input type="email" name="email" value={email} onChange={handleChange} required />

                <label>Mot de passe :</label>
                <input type="password" name="password" value={password} onChange={handleChange} required />

                <label>Confirmer Mot de passe :</label>
                <input type="password" name="confirmPassword" value={confirmPassword} onChange={handleChange} required />

                <button type="submit">S'inscrire</button>
            </form>
        </div>
    );
}

export default Signup;

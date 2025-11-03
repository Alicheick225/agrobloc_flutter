import axios from "axios";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

function Livre() {
    const [title, settitle] = useState('');
    const [author, setauthor] = useState('');
    const [file, setfile] = useState(null); 
    const navigate = useNavigate();

    const handleChange = (e) => {
        e.preventDefault();
        const { name, value, files } = e.target;

        if (name === 'title') {
            settitle(value);
        }
        if (name === 'author') {
            setauthor(value);
        }
        if (name === 'file') {
            setfile(files[0]); 
        }

        console.log(name);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        console.log('je suis dans la fonction handleSubmit');

        try {
            const token = localStorage.getItem('authToken');
            const response = await axios.post('http://192.168.252.45:3000/fichier/ajouter', {
                nom: title,
                proprietaire: author,

            }, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                },
            });
            console.log(response);
            if (response) {
                navigate('/'); 
            }
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div>
            <h1>Ajouter un Nouveau Document</h1>
            <form onSubmit={handleSubmit}> {    }
                <label>Titre du document :</label>
                <input type="text" name="title" required onChange={handleChange} /> {/* Ajoutez onChange */}

                <label>Auteur :</label>
                <input type="text" name="author" required onChange={handleChange} /> {/* Ajoutez onChange */}

                <label>Fichier :</label>
                <input type="file" accept=".pdf, .xls, .xlsx, .ppt, .pptx" onChange={handleChange} required name="file" />

                <button type="submit">Enregistrer</button>
            </form>
        </div>
    );
}

export default Livre;

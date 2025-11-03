import axios from "axios";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

function Login({ onLogin }) {
    const [password, setPassword] = useState('')
    const [email, setEmail] = useState('')
    const navigate = useNavigate()
    const handleChange = (e) => {
        e.preventDefault()
        const {name, value} = e.target

        if (name  === 'password' ) {
          setPassword(value)
        }
        if (name === 'email') {
          setEmail(value)
        }
        
        console.log(name)
    }
    const handleSubmit = async (e) => {

      e.preventDefault()
      console.log('je suis dans la fonction handlesubmit')
      await axios.post('http://192.168.252.45:3000/auth/connexion', {email:email, motDePasse:password})
      .then(response => {
        console.log(response)
        if (response) {
          onLogin(response.data.token)
          navigate('/')
        }
      })
      .catch(err => {throw new Error(err)})

    }

    return (
      <div>
        <h1>Connexion</h1>
        <form>
          <label>Email :</label>
          <input value={email} onChange={(e) => {handleChange(e)}} type="email" name="email" required />
  
          <label>Mot de passe :</label>
          <input value={password} onChange={(e) => {handleChange(e)}} type="password" name="password" required />
  
          <button onClick={handleSubmit} type="submit">Se connecter</button>
        </form>
      </div>
    );
  }
  
  export default Login;
  
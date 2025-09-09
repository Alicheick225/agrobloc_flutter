class AuthentificationModel {
  final String id;
  final String nom;
  final String? email;
  final String? photoUrl; // Ajout du champ photoUrl
  final String? numeroTel;
  final String profilId;
  final String? walletAdress;
  final bool? isProfileCompleted;
  final String? token;

  AuthentificationModel({
    required this.id,
    required this.nom,
    this.email,
    this.photoUrl,
    this.numeroTel,
    required this.profilId,
    this.walletAdress,
    this.isProfileCompleted,
    this.token,
  });

  factory AuthentificationModel.fromJson(Map<String, dynamic> json) {
    return AuthentificationModel(
      id: json['id'] != null ? json['id'] as String : '',
      nom: json['nom'] != null ? json['nom'] as String : '',
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?, // Ajout du champ photoUrl
      numeroTel: json['numero_tel'] as String?,
      profilId: json['profil_id'] != null ? json['profil_id'] as String : '',
      walletAdress: json['wallet_adress'] as String?,
      isProfileCompleted: json['is_profile_completed'] as bool?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'photo_url': photoUrl, // Ajout du champ photoUrl
      'numero_tel': numeroTel,
      'profil_id': profilId,
      'wallet_adress': walletAdress,
      'is_profile_completed': isProfileCompleted,
      'token': token,
    };
  }
}

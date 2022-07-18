class RegisterDetails {
  RegisterDetails({
    this.nome,
    this.cpf,
    this.email,
    this.password,
    this.telefone,
    this.aceiteTermo = false,
  });

  String? nome;
  String? cpf;
  String? email;
  String? password;
  String? telefone;
  bool aceiteTermo;

  bool checkIsCompleted() {
    if (nome != null &&
        nome!.isNotEmpty &&
        cpf != null &&
        cpf!.isNotEmpty &&
        email != null &&
        email!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty &&
        telefone != null &&
        telefone!.isNotEmpty &&
        aceiteTermo) {
      return true;
    } else {
      return false;
    }
  }
}

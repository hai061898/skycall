class Utils {
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplite = name.split(' ');
    String firstNameInitial = nameSplite[0][0];
    String lastNameInitial = nameSplite[1][0];

    return firstNameInitial + lastNameInitial;
  }
}

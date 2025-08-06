String getLogoUrl(String? logoPath) {
  if (logoPath == null || logoPath.isEmpty) return "";
  if (logoPath.startsWith("http")) return logoPath;

  const baseUrl = "http://192.168.252.28:8082"; // adapte à ton cas
  final normalizedPath = logoPath.startsWith("/") ? logoPath : "/images/$logoPath";
  final url = "$baseUrl$normalizedPath";

  print("🔗 LOGO URL: $url");
  return url;
}

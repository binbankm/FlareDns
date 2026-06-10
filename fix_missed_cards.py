import os

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # ssl_page.dart
    ssl_str = """elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),"""
    content = content.replace(ssl_str, "")

    # zone_dashboard_page.dart
    z1 = """elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purpleAccent.withValues(alpha: 0.3)),
      ),"""
    content = content.replace(z1, "")

    z2 = """elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),"""
    content = content.replace(z2, "")

    # worker_dashboard_page.dart
    w1 = """elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: color.withValues(alpha: 0.3)),
              ),"""
    content = content.replace(w1, "")

    w2 = """elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),"""
    content = content.replace(w2, "")

    w3 = """elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),"""
    content = content.replace(w3, "")

    w4 = """elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),"""
    content = content.replace(w4, "")

    w5 = """elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.purple.withValues(alpha: 0.3),
                        ),
                      ),"""
    content = content.replace(w5, "")

    # dns_records_list_page.dart
    d1 = """elevation: 1,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),"""
    content = content.replace(d1, "")

    # page_dashboard_page.dart
    p1 = """elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),"""
    content = content.replace(p1, "")

    p2 = """elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),"""
    content = content.replace(p2, "")

    with open(filepath, 'w') as f:
        f.write(content)

for root, dirs, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))


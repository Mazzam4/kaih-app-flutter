import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/common/widgets/primary_button.dart';
import 'package:kaih_7_xirpl2/core/configs/assets/app_images.dart';
import 'package:kaih_7_xirpl2/core/configs/theme/app_colors.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/create_organization_page.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/join_organization_page.dart';

class OrgSelectionPage extends StatelessWidget {
  const OrgSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppImages.chat, width: 200, height: 200),
                  const SizedBox(height: 20),
                  Text(
                    "Pilih Aksi Organisasi",
                    style: textTheme.titleLarge?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Kamu bisa membuat organisasi baru atau bergabung dengan yang sudah ada.",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  PrimaryButton(
                    text: "BUAT ORGANISASI BARU",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateOrganizationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JoinOrganizationPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "GABUNG KE ORGANISASI",
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
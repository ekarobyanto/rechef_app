import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechef_app/src/features/auth/presentation/register/register_steps/cubit/select_gender_cubit.dart';
import 'package:rechef_app/src/features/shared/shrink_button.dart';

import '../../../../../constants/image_path.dart';
import '../../../../../constants/styles.dart';
import 'widgets/select_gender.dart';

class ChooseGender extends StatelessWidget {
  const ChooseGender({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              genderDecor,
              scale: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Pilih jenis kelamin',
              style: Styles.font.blg,
            ),
            const SizedBox(
              height: 20,
            ),
            const SelectGender(),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 50,
              child: ShrinkButton(
                text: 'Selanjutnya',
                onTap: () {
                  var value = context.read<GenderCubit>().state;
                  log(value);
                  if (value != '') {
                    onBack();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

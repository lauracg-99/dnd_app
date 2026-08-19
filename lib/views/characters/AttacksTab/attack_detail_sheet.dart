import 'package:dnd_app/helpers/character_ability_helper.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/services/dice_service.dart';
import 'package:flutter/material.dart';

class AttackDetailSheet extends StatefulWidget {
  final CharacterAttack attack;
  final void Function(CharacterAttack)? onSave;

  const AttackDetailSheet({super.key, required this.attack, this.onSave});

  @override
  State<AttackDetailSheet> createState() => _AttackDetailSheetState();
}

class _AttackDetailSheetState extends State<AttackDetailSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _attackBonusController;
  late final TextEditingController _damageController;
  late final TextEditingController _damageTypeController;

  String? _attackResult;
  String? _damageResult;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.attack.name);
    _attackBonusController = TextEditingController(
      text: widget.attack.attackBonus,
    );
    _damageController = TextEditingController(text: widget.attack.damage);
    _damageTypeController = TextEditingController(
      text: widget.attack.damageType,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _attackBonusController.dispose();
    _damageController.dispose();
    _damageTypeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedAttack = CharacterAttack(
      id: widget.attack.id,
      name:
          _nameController.text.trim().isEmpty
              ? widget.attack.name
              : _nameController.text.trim(),
      attackBonus: _attackBonusController.text.trim(),
      damage: _damageController.text.trim(),
      damageType: _damageTypeController.text.trim(),
    );

    widget.onSave?.call(updatedAttack);
    Navigator.of(context).pop(updatedAttack);
  }

  @override
  Widget build(BuildContext context) {
    final currentAttackBonus = _attackBonusController.text.trim();
    final currentDamage = _damageController.text.trim();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder:
          (context, scrollController) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Edit Attack',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditableField('Name', _nameController),
                          const SizedBox(height: 16),
                          _buildEditableField(
                            'Attack Bonus',
                            _attackBonusController,
                          ),
                          const SizedBox(height: 16),
                          _buildEditableField('Damage', _damageController),
                          const SizedBox(height: 16),
                          _buildEditableField(
                            'Damage Type',
                            _damageTypeController,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () async {
                              final diceExpression =
                                  currentAttackBonus.isEmpty
                                      ? '1d20'
                                      : '1d20$currentAttackBonus';
                              final res = await DiceService.lanzarDadosResult(
                                context,
                                diceExpression,
                              );
                              if (res != null) {
                                setState(() {
                                  _attackResult = res;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700]!,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  CharacterAbilityHelper.getDiceAsset('d20'),
                                  width: 22,
                                  height: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Roll Attack: 1d20${currentAttackBonus.isEmpty ? '' : currentAttackBonus}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          if (_attackResult != null) ...[
                            const SizedBox(height: 8),
                            _buildResultSquare(_attackResult, Colors.blue[700]),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final diceExpression = currentDamage.replaceAll(
                                ' ',
                                '',
                              );
                              final res = await DiceService.lanzarDadosResult(
                                context,
                                diceExpression.isEmpty ? '1d8' : diceExpression,
                              );
                              if (res != null) {
                                setState(() {
                                  _damageResult = res;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700]!,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  CharacterAbilityHelper.getDiceAsset('d8'),
                                  width: 22,
                                  height: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Roll Damage: ${currentDamage.isEmpty ? '1d8' : currentDamage.replaceAll(' ', '')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          if (_damageResult != null) ...[
                            const SizedBox(height: 8),
                            _buildResultSquare(
                              _damageResult,
                              Colors.purple[700],
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveChanges,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildResultSquare(String? result, Color? color) {
    if (result == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        result,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

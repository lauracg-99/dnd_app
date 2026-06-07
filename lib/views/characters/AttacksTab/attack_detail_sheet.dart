import 'package:dnd_app/helpers/character_ability_helper.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/services/dice_service.dart';
import 'package:flutter/material.dart';

class AttackDetailSheet extends StatefulWidget {
  final CharacterAttack attack;

  const AttackDetailSheet({super.key, required this.attack});

  @override
  State<AttackDetailSheet> createState() => _AttackDetailSheetState();
}

class _AttackDetailSheetState extends State<AttackDetailSheet> {
  String? _attackResult;
  String? _damageResult;

  @override
  Widget build(BuildContext context) {
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
                // Barra superior
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
                // Cabecera
                Text(
                  widget.attack.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Contenido
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(
                            'Attack Bonus',
                            widget.attack.attackBonus,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailSection('Damage', widget.attack.damage),
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            'Damage Type',
                            widget.attack.damageType,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () async {
                              final res = await DiceService.lanzarDadosResult(
                                context,
                                "1d20+${widget.attack.attackBonus}",
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
                                  'Roll Attack: 1d20${widget.attack.attackBonus}',
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
                              final res = await DiceService.lanzarDadosResult(
                                context,
                                widget.attack.damage.replaceAll(' ', ''),
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
                                  'Roll Damage: ${widget.attack.damage.replaceAll(' ', '')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          if (_damageResult != null) ...[
                            const SizedBox(height: 8),
                            _buildResultSquare(_damageResult, Colors.purple[700],),
                          ],
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

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(content, style: const TextStyle(fontSize: 16)),
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

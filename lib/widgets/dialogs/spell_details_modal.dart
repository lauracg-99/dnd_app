import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/services/dice_service.dart';
import 'package:dnd_app/services/spell_service.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/models/spell_model.dart';
import 'package:dnd_app/widgets/detail_row.dart';

class SpellDetailsModal extends StatefulWidget {
  final Spell spell;
  final Character character;
  final String characterModifier;
  final String characterAttack;
  final void Function(Spell spell) onRemoveSpell;

  const SpellDetailsModal({
    super.key,
    required this.spell,
    required this.character,
    required this.characterModifier,
    required this.characterAttack,
    required this.onRemoveSpell,
  });

  @override
  State<SpellDetailsModal> createState() => _SpellDetailsModalState();
}

class _SpellDetailsModalState extends State<SpellDetailsModal> {
  // Variables para almacenar los resultados de las tiradas
  String? _attackResult;
  // Usamos un mapa para registrar el resultado de cada dado de daño individualmente
  final Map<int, String> _damageResults = {};

  String _formatComponents(Spell spell) {
    final components = <String>[];
    if (spell.verbal) components.add('V');
    if (spell.somatic) components.add('S');
    if (spell.material && spell.components != null) {
      components.add('M (${spell.components})');
    }
    return components.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
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
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      widget.spell.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      SpellService.formatSchoolAndLevel(widget.spell),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DetailRow(
                      label: 'Casting Time',
                      value: widget.spell.castingTime,
                    ),
                    DetailRow(label: 'Range', value: widget.spell.range),
                    DetailRow(
                      label: 'Components',
                      value: _formatComponents(widget.spell),
                    ),
                    DetailRow(label: 'Duration', value: widget.spell.duration),
                    if (widget.spell.ritual)
                      DetailRow(label: 'Ritual', value: 'Yes'),
                    DetailRow(
                      label: 'Classes',
                      value: SpellService.formatClasses(widget.spell),
                    ),
                    const Divider(),
                    const SizedBox(height: 5),
                    DetailRow(label: 'Description', value: ''),
                    Text(
                      widget.spell.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.spell.higherLevelDescription != null &&
                        widget.spell.higherLevelDescription!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DetailRow(label: 'At Higher Levels', value: ''),
                      Text(
                        widget.spell.higherLevelDescription ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],

                    const SizedBox(height: 16),
                    if (widget.spell.description.toLowerCase().contains(
                      'ranged spell attack',
                    )) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailRow(
                            label: 'Attack',
                            value: "1d20+${widget.characterAttack}",
                          ),

                          ElevatedButton(
                            onPressed: () async {
                              final res = await DiceService.lanzarDadosResult(
                                context,
                                "1d20+${widget.characterAttack}",
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
                                  _getDiceAsset('d8'),
                                  width: 22,
                                  height: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Roll Attack: 1d20+${widget.characterAttack}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_attackResult != null) ...[
                            const SizedBox(height: 8),
                            _buildResultSquare(_attackResult, Colors.blue[700]),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (widget.spell.damageDice.isNotEmpty) ...[
                      ...widget.spell.damageDice.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final dice = entry.value;
                        final characterMod = widget.characterModifier;
                        final descriptionLower = widget.spell.description.toLowerCase();
                        final hasSpellcastingModifier = descriptionLower.contains('spellcasting ability modifier') || 
                                 descriptionLower.contains('saving throw');
                        final diceString =
                            hasSpellcastingModifier
                                ? '${dice.diceAmount}${dice.diceType}+${characterMod}'
                                : '${dice.diceAmount}${dice.diceType}';

                        Color baseDiceColor;
                        switch (dice.diceType.toLowerCase()) {
                          case 'd4':
                            baseDiceColor = Colors.yellow[700]!;
                            break;
                          case 'd6':
                            baseDiceColor = Colors.green[700]!;
                            break;
                          case 'd8':
                            baseDiceColor = Colors.teal[700]!;
                            break;
                          case 'd10':
                            baseDiceColor = Colors.orange[700]!;
                            break;
                          case 'd12':
                            baseDiceColor = Colors.pink[800]!;
                            break;
                          default:
                            baseDiceColor = Colors.blueGrey[700]!;
                        }

                        final double lerpFactor = ((dice.diceAmount - 1) * 0.10)
                            .clamp(0.0, 0.8);
                        final Color finalColor =
                            Color.lerp(
                              baseDiceColor,
                              Colors.black,
                              lerpFactor,
                            )!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Builder(
                            builder: (context) {
                              final currentDamageResult = _damageResults[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [  
                                  if (index == 0) ...[
                                     DetailRow(label: 'Dices', value: ''),                           
                                  ], 
                                  if (index != 0) ...[
                                     Divider()                              
                                  ],
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          final res =
                                              await DiceService.lanzarDadosResult(
                                                context,
                                                diceString,
                                              );
                                          if (res != null) {
                                            setState(() {
                                              _damageResults[index] = res;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: finalColor,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              _getDiceAsset('d8'),
                                              width: 22,
                                              height: 22,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Roll Damage: $diceString',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Si hay resultado, se mostrará aquí abajo
                                      if (currentDamageResult != null) ...[
                                        const SizedBox(
                                          height: 8,
                                        ), // Espacio entre el botón y el resultado
                                        _buildResultSquare(
                                          currentDamageResult,
                                          Colors.purple[700],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  String _getDiceAsset(String type) {
    switch (type.toLowerCase()) {
      case 'd4':
        return 'assets/icon/white-d6.png';
      case 'd6':
        return 'assets/icon/white-d6.png';
      case 'd8':
        return 'assets/icon/white-d8.png';
      case 'd10':
        return 'assets/icon/white-d20.png';
      case 'd12':
        return 'assets/icon/white-d20.png';
      case 'd100':
        return 'assets/icon/white-d20.png';
      case 'd20':
      default:
        return 'assets/icon/white-d20.png';
    }
  }

}

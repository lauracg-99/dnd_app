import 'package:dnd_app/main.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:dart_dice_parser/dart_dice_parser.dart';

class DiceService {
  static Future<void> simulateDice() async {
    // Define the number of tumbles/bounces
    const int totalBounces = 9;

    // Initial delay between the first few impacts (in milliseconds)
    int currentDelay = 20;

    for (int i = 0; i < totalBounces; i++) {
      // 1. Trigger the haptic tick based on the progression of the roll
      if (i < 3) {
        // First couple of impacts are heavy/medium (hard table hits)
        await HapticFeedback.vibrate();
        await HapticFeedback.heavyImpact();
      } else if (i < 6) {
        // Mid-roll settles into lighter tumbles
        await HapticFeedback.mediumImpact();
      } else {
        // Final micro-settling ticks
        await HapticFeedback.lightImpact();
      }

      // 2. Increase the delay dynamically to simulate loss of speed (decay)
      // Adding 25-35ms to each gap stretches out the final bounces
      currentDelay += (15 + (i * 4));

      // 3. Wait for the calculated delay before the next bounce
      await Future.delayed(Duration(milliseconds: currentDelay));
    }
  }

  // Lanza una expresión de dados una sola vez
  static Future<void> lanzarDados(
    BuildContext context,
    String expresion,
  ) async {
    try {
      final formula = DiceExpression.create(expresion);
      final resultado = formula.roll();

      // Asegura que el widget siga montado antes de usar el context de forma asíncrona
      if (!context.mounted) return;

      scaffoldMessengerKey.currentState?.clearSnackBars();

      SnackbarHelper.showInfo(
        context,
        "Total: ${resultado.total} ${resultado.detailedResults} ${resultado.expression}",
        duration: const Duration(seconds: 20),
      );

      await simulateDice();
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showInfo(context, "Error en la fórmula: $expresion");
    }
  }

static Future<String?> lanzarDadosResult(
  BuildContext context,
  String expresion,
) async {
  try {
    final formula = DiceExpression.create(expresion);
    final resultado = formula.roll();
    
    // --- CORRECCIÓN AQUÍ ---
    // Forzamos la conversión a String usando .toString()
    final String detalleStr = resultado.detailedResults.toString();
    // ------------------------
    
    debugPrint("Lanzando dados con expresión: $expresion resultado: ${resultado.total} detalles: $detalleStr");
    
    if (!context.mounted) return null;

    scaffoldMessengerKey.currentState?.clearSnackBars();
    await HapticFeedback.heavyImpact();

    List<int> dadosLanzados = [];
    final rolledRegex = RegExp(r'rolled:\s*\[([\d\s,]+)\]');
    final rolledMatch = rolledRegex.firstMatch(detalleStr);

    if (rolledMatch != null && rolledMatch.group(1) != null) {
      dadosLanzados = rolledMatch.group(1)!
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
    } else {
      dadosLanzados = List<int>.from(resultado.results);
    }

    int bono = 0;
    final stringLimpio = expresion.replaceAll(' ', '');
    final bonoRegex = RegExp(r'([\+\-])(\d+)$'); 
    final bonoMatch = bonoRegex.firstMatch(stringLimpio);

    if (bonoMatch != null) {
      final signo = bonoMatch.group(1);
      final valor = int.parse(bonoMatch.group(2)!);
      bono = (signo == '+') ? valor : -valor;
    }

    List<int> dadosUI = List<int>.from(resultado.results);
    if (bono != 0 && dadosUI.contains(bono.abs()) && dadosUI.length > 1) {
      dadosUI.removeLast(); 
    }
    
    if (dadosUI.isEmpty && dadosLanzados.isNotEmpty) {
      dadosUI = dadosLanzados;
    }

    final String dadosTexto = "Dados: $dadosUI";
    
    if (bono > 0) {
      return "Total: ${resultado.total} · $dadosTexto · Bono: +$bono";
    } else if (bono < 0) {
      return "Total: ${resultado.total} · $dadosTexto · Bono: $bono";
    } else {
      return "Total: ${resultado.total} · $dadosTexto";
    }

  } catch (e) {
    if (context.mounted) {
      SnackbarHelper.showInfo(context, "Error en la fórmula: $expresion");
    }
    return null;
  }
}

  // Lanza una expresión de dados múltiples veces de forma consecutiva
  static Future<void> lanzarVariasVeces(
    BuildContext context,
    String expresion,
    int totalDeTiradas,
  ) async {
    try {
      final formula = DiceExpression.create(expresion);

      await for (final tirada in formula.rollN(totalDeTiradas)) {
        await simulateDice();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).clearSnackBars();

        SnackbarHelper.showInfo(
          context,
          "Total tirada: ${tirada.total} ${tirada.detailedResults} ${tirada.expression}",
          duration: const Duration(seconds: 20),
        );

        // Pequeña pausa entre tiradas completas para que no se encabalquen los SnackBars
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showInfo(context, "Error en la fórmula: $expresion");
    }
  }
}

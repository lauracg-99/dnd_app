import '../models/character_model.dart';

class SkillUpdateHelper {
  static CharacterSkillChecks updateProficiency(
    CharacterSkillChecks current,
    String skill,
    bool value,
  ) {
    final Map<String, bool> proficiencies = {
      'acrobatics': current.acrobaticsProficiency,
      'animal_handling': current.animalHandlingProficiency,
      'arcana': current.arcanaProficiency,
      'athletics': current.athleticsProficiency,
      'deception': current.deceptionProficiency,
      'history': current.historyProficiency,
      'insight': current.insightProficiency,
      'intimidation': current.intimidationProficiency,
      'investigation': current.investigationProficiency,
      'medicine': current.medicineProficiency,
      'nature': current.natureProficiency,
      'perception': current.perceptionProficiency,
      'performance': current.performanceProficiency,
      'persuasion': current.persuasionProficiency,
      'religion': current.religionProficiency,
      'sleight_of_hand': current.sleightOfHandProficiency,
      'stealth': current.stealthProficiency,
      'survival': current.survivalProficiency,
    };

    final Map<String, bool> expertises = {
      'acrobatics': current.acrobaticsExpertise,
      'animal_handling': current.animalHandlingExpertise,
      'arcana': current.arcanaExpertise,
      'athletics': current.athleticsExpertise,
      'deception': current.deceptionExpertise,
      'history': current.historyExpertise,
      'insight': current.insightExpertise,
      'intimidation': current.intimidationExpertise,
      'investigation': current.investigationExpertise,
      'medicine': current.medicineExpertise,
      'nature': current.natureExpertise,
      'perception': current.perceptionExpertise,
      'performance': current.performanceExpertise,
      'persuasion': current.persuasionExpertise,
      'religion': current.religionExpertise,
      'sleight_of_hand': current.sleightOfHandExpertise,
      'stealth': current.stealthExpertise,
      'survival': current.survivalExpertise,
    };

    proficiencies[skill] = value;
    if (!value) {
      expertises[skill] = false;
    }

    return CharacterSkillChecks(
      acrobaticsProficiency: proficiencies['acrobatics']!,
      acrobaticsExpertise: expertises['acrobatics']!,
      animalHandlingProficiency: proficiencies['animal_handling']!,
      animalHandlingExpertise: expertises['animal_handling']!,
      arcanaProficiency: proficiencies['arcana']!,
      arcanaExpertise: expertises['arcana']!,
      athleticsProficiency: proficiencies['athletics']!,
      athleticsExpertise: expertises['athletics']!,
      deceptionProficiency: proficiencies['deception']!,
      deceptionExpertise: expertises['deception']!,
      historyProficiency: proficiencies['history']!,
      historyExpertise: expertises['history']!,
      insightProficiency: proficiencies['insight']!,
      insightExpertise: expertises['insight']!,
      intimidationProficiency: proficiencies['intimidation']!,
      intimidationExpertise: expertises['intimidation']!,
      investigationProficiency: proficiencies['investigation']!,
      investigationExpertise: expertises['investigation']!,
      medicineProficiency: proficiencies['medicine']!,
      medicineExpertise: expertises['medicine']!,
      natureProficiency: proficiencies['nature']!,
      natureExpertise: expertises['nature']!,
      perceptionProficiency: proficiencies['perception']!,
      perceptionExpertise: expertises['perception']!,
      performanceProficiency: proficiencies['performance']!,
      performanceExpertise: expertises['performance']!,
      persuasionProficiency: proficiencies['persuasion']!,
      persuasionExpertise: expertises['persuasion']!,
      religionProficiency: proficiencies['religion']!,
      religionExpertise: expertises['religion']!,
      sleightOfHandProficiency: proficiencies['sleight_of_hand']!,
      sleightOfHandExpertise: expertises['sleight_of_hand']!,
      stealthProficiency: proficiencies['stealth']!,
      stealthExpertise: expertises['stealth']!,
      survivalProficiency: proficiencies['survival']!,
      survivalExpertise: expertises['survival']!,
    );
  }

  static CharacterSkillChecks updateExpertise(
    CharacterSkillChecks current,
    String skill,
    bool value,
  ) {
    final Map<String, bool> proficiencies = {
      'acrobatics': current.acrobaticsProficiency,
      'animal_handling': current.animalHandlingProficiency,
      'arcana': current.arcanaProficiency,
      'athletics': current.athleticsProficiency,
      'deception': current.deceptionProficiency,
      'history': current.historyProficiency,
      'insight': current.insightProficiency,
      'intimidation': current.intimidationProficiency,
      'investigation': current.investigationProficiency,
      'medicine': current.medicineProficiency,
      'nature': current.natureProficiency,
      'perception': current.perceptionProficiency,
      'performance': current.performanceProficiency,
      'persuasion': current.persuasionProficiency,
      'religion': current.religionProficiency,
      'sleight_of_hand': current.sleightOfHandProficiency,
      'stealth': current.stealthProficiency,
      'survival': current.survivalProficiency,
    };

    final Map<String, bool> expertises = {
      'acrobatics': current.acrobaticsExpertise,
      'animal_handling': current.animalHandlingExpertise,
      'arcana': current.arcanaExpertise,
      'athletics': current.athleticsExpertise,
      'deception': current.deceptionExpertise,
      'history': current.historyExpertise,
      'insight': current.insightExpertise,
      'intimidation': current.intimidationExpertise,
      'investigation': current.investigationExpertise,
      'medicine': current.medicineExpertise,
      'nature': current.natureExpertise,
      'perception': current.perceptionExpertise,
      'performance': current.performanceExpertise,
      'persuasion': current.persuasionExpertise,
      'religion': current.religionExpertise,
      'sleight_of_hand': current.sleightOfHandExpertise,
      'stealth': current.stealthExpertise,
      'survival': current.survivalExpertise,
    };

    expertises[skill] = value;
    if (value) {
      proficiencies[skill] = true;
    }

    return CharacterSkillChecks(
      acrobaticsProficiency: proficiencies['acrobatics']!,
      acrobaticsExpertise: expertises['acrobatics']!,
      animalHandlingProficiency: proficiencies['animal_handling']!,
      animalHandlingExpertise: expertises['animal_handling']!,
      arcanaProficiency: proficiencies['arcana']!,
      arcanaExpertise: expertises['arcana']!,
      athleticsProficiency: proficiencies['athletics']!,
      athleticsExpertise: expertises['athletics']!,
      deceptionProficiency: proficiencies['deception']!,
      deceptionExpertise: expertises['deception']!,
      historyProficiency: proficiencies['history']!,
      historyExpertise: expertises['history']!,
      insightProficiency: proficiencies['insight']!,
      insightExpertise: expertises['insight']!,
      intimidationProficiency: proficiencies['intimidation']!,
      intimidationExpertise: expertises['intimidation']!,
      investigationProficiency: proficiencies['investigation']!,
      investigationExpertise: expertises['investigation']!,
      medicineProficiency: proficiencies['medicine']!,
      medicineExpertise: expertises['medicine']!,
      natureProficiency: proficiencies['nature']!,
      natureExpertise: expertises['nature']!,
      perceptionProficiency: proficiencies['perception']!,
      perceptionExpertise: expertises['perception']!,
      performanceProficiency: proficiencies['performance']!,
      performanceExpertise: expertises['performance']!,
      persuasionProficiency: proficiencies['persuasion']!,
      persuasionExpertise: expertises['persuasion']!,
      religionProficiency: proficiencies['religion']!,
      religionExpertise: expertises['religion']!,
      sleightOfHandProficiency: proficiencies['sleight_of_hand']!,
      sleightOfHandExpertise: expertises['sleight_of_hand']!,
      stealthProficiency: proficiencies['stealth']!,
      stealthExpertise: expertises['stealth']!,
      survivalProficiency: proficiencies['survival']!,
      survivalExpertise: expertises['survival']!,
    );
  }
}

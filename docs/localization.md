# Localization Guide

## Overview

This guide provides instructions for localizing the CollectionBuilder interface, allowing for different languages to be used in the GUI.

## Configuring Language

Set the default language with the `lang` field in `_config.yml` using two-letter [ISO language codes](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes). The default is English (`en`). If the language is not supported or incomplete, the default language will be used.

**Note:** Currently, German (`de`) and Spanish (`es`) are supported. Adding other languages requires manual translation.

## Customizing Translations

Translations are managed in the `_data/translations.yml` file, linking GUI elements to their respective translations. Each field has a default English value in the HTML file, replaced with the appropriate translation based on the defined language.

If you want to localize the datatables you need to download the language file from the [datatables website](https://datatables.net/plug-ins/i18n/) and add it to the `lib/datatables` folder with the same name as the language code.

## File Structure

Each GUI element or label is translated individually. The structure of the `_data/translations.yml` file is as follows:

```yaml
nameOfFolder:
  nameOfHTMLFile:
    nameOfField:
      en: "English Translation"
      es: "Traducción española"
      de: "Deutsche Übersetzung"
...
```

## Adding New Languages

Extend the `_data/translations.yml` file with entries for the new language.

## Unique Fields Approach

Using unique fields for each translation maintains simplicity and enhances accessibility, despite potential duplication.

## Translation Guidelines

- **Gender Neutrality:** Use gender-neutral language to accommodate all users.
- **Cultural Sensitivity:** Be aware of cultural nuances and meanings.
- **Consistency:** Maintain consistency in terminology and style.
- **Clarity:** Ensure translations are clear and easy to understand.
- **Context:** Consider the context in which terms are used.
- **Length:** Keep translations concise to avoid layout issues.
- **Plurals:** Account for plural forms and grammatical rules. Try to use the same plural form as the default language.

## Contributions

We welcome contributions to extend the language support. Discuss the addition of a new language in [CollectionBuilder discussions](https://github.com/orgs/CollectionBuilder/discussions) or [open an issue](https://github.com/CollectionBuilder/collectionbuilder-csv/issues/new/choose). We accept pull requests for new languages, aiming for complete and consistent translations.

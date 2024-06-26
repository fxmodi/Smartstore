﻿namespace Smartstore.Core.Platform.AI
{
    /// <summary>
    /// Represents the AI modal dialog type.
    /// </summary>
    public enum AIModalDialogType
    {
        /// <summary>
        /// Used to open a modal dialog for image creation.
        /// </summary>
        Image = 10,

        /// <summary>
        /// Used to open a modal dialog for simple text creation.
        /// </summary>
        Text = 20,

        /// <summary>
        /// Used to open a modal dialog for rich text creation.
        /// </summary>
        RichText = 30,

        /// <summary>
        /// Used to open a modal dialog for translations.
        /// </summary>
        Translation = 40,

        /// <summary>
        /// Used to open a modal dialog for suggestions.
        /// </summary>
        Suggestion = 50
    }

    /// <summary>
    /// Represents the AI image creation type.
    /// </summary>
    public enum AIImageCreationFormat
    {
        Horizontal = 10,
        Vertical = 20,
        Square = 30
    }

    /// <summary>
    /// Represents the AI role.
    /// </summary>
    public enum AIRole
    {
        Translator = 10,
        Copywriter = 20,
        Marketer = 30,
        SEOExpert = 40,
        Blogger = 50,
        Journalist = 60,
        SalesPerson = 70,
        ProductExpert = 80
    }
}
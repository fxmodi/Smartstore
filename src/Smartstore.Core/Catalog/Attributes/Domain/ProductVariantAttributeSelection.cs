﻿using System;
using System.ComponentModel;
using System.Xml;
using System.Xml.Linq;
using Smartstore.Collections;
using Smartstore.Core.Checkout.GiftCards;
using Smartstore.Domain;

namespace Smartstore.Core.Catalog.Attributes
{
    /// <summary>
    /// Represents a product variant attribute selection.
    /// </summary>
    /// <remarks>
    /// This class can parse strings with XML or JSON format to <see cref="Multimap{int, object}"/> and vice versa.
    /// </remarks>
    public class ProductVariantAttributeSelection : AttributeSelection
    {
        /// <summary>
        /// Creates product variant attribute selection from string as <see cref="Multimap{int, object}"/>. 
        /// Use <see cref="AttributeSelection.AttributesMap"/> to access parsed attributes afterwards.
        /// </summary>
        /// <remarks>
        /// Automatically differentiates between XML and JSON.
        /// </remarks>
        /// <param name="rawAttributes">XML or JSON attributes string.</param>  
        public ProductVariantAttributeSelection(string rawAttributes)
            : base(rawAttributes, "ProductVariantAttribute")
        {
        }

        /// <summary>
        /// Gets or sets gift card info
        /// </summary>
        public GiftCardInfo GiftCardInfo { get; set; }

        protected override void MapUnknownElement(XElement element, Multimap<int, object> map)
        {
            if (element.Name.LocalName == "GiftCardInfo")
            {
                try
                {
                    GiftCardInfo = new GiftCardInfo();

                    foreach (var el in element.Elements())
                    {
                        switch (el.Name.LocalName)
                        {
                            case nameof(GiftCardInfo.RecipientEmail):
                                GiftCardInfo.RecipientEmail = el.Value;
                                break;
                            case nameof(GiftCardInfo.RecipientName):
                                GiftCardInfo.RecipientName = el.Value;
                                break;
                            case nameof(GiftCardInfo.SenderName):
                                GiftCardInfo.SenderName = el.Value;
                                break;
                            case nameof(GiftCardInfo.SenderEmail):
                                GiftCardInfo.SenderEmail = el.Value;
                                break;
                            case nameof(GiftCardInfo.Message):
                                GiftCardInfo.Message = el.Value;
                                break;
                            default:
                                throw new InvalidEnumArgumentException(el.Name.LocalName);
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new XmlException("Error while trying to parse from additional XML: " + nameof(ProductVariantAttributeSelection), ex);
                }
            }
        }

        protected override void OnSerialize(XElement root)
        {
            if (GiftCardInfo != null)
            {
                var el = new XElement("GiftCardInfo");
                el.Add(new XElement(nameof(GiftCardInfo.RecipientName), GiftCardInfo.RecipientName));
                el.Add(new XElement(nameof(GiftCardInfo.RecipientEmail), GiftCardInfo.RecipientEmail));
                el.Add(new XElement(nameof(GiftCardInfo.SenderName), GiftCardInfo.SenderName));
                el.Add(new XElement(nameof(GiftCardInfo.SenderEmail), GiftCardInfo.SenderEmail));
                el.Add(new XElement(nameof(GiftCardInfo.Message), GiftCardInfo.Message));

                root.Add(el);
            }
        }
    }
}
//
//  Varekategori.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 06/08/2020.
//

import Foundation

enum Varekategori: String, Codable {
    case Bakeri, Barneprodukter, Dessert, Drikke, Dyr, Fisk, Middag, Middagstilbehør, Ost, Kioskvarer, Kjøtt, Anna
    case BakevarerKjeks = "Bakevarer og kjeks"
    case FruktGrønt = "Frukt og grønt"
    case HusHjem = "Hus & hjem"
    case MeieriEgg = "Meieri & egg"
    case PersonlegeArtiklar = "Personlige artikler"
    case PåleggFrokost = "Pålegg & frokost"
    case SnacksGodteri = "Snacks & godteri"
}

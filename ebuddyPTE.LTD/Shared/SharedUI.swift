//
//  SharedUI.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI
import PhotosUI

struct Spinner: View {
    @State private var rotationAngle = 0.0
    private let ringSize: CGFloat = 80

    var colors: [Color] = [Color.red, Color.red.opacity(0.3)]

    var body: some View {
        ZStack(content: {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .ignoresSafeArea()
            
            ZStack(content: {
                Circle()
                   .stroke(
                       AngularGradient(
                           gradient: Gradient(colors: colors),
                           center: .center,
                           startAngle: .degrees(0),
                           endAngle: .degrees(360)
                       ),
                       style: StrokeStyle(lineWidth: 16, lineCap: .round)
                       
                   )
                   .frame(width: ringSize, height: ringSize)

                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.red)
                    .offset(x: ringSize/2)
            })
            .rotationEffect(.degrees(rotationAngle))
            .padding(.horizontal, 80)
            .padding(.vertical, 50)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .onAppear(perform: {
                withAnimation(.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)) {
                    rotationAngle = 360.0
                }
            })
            .onDisappear(perform: {
                rotationAngle = 0.0
            })
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

func countryFlag(_ countryCode: String) -> String {
    String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
        UnicodeScalar(127397 + $0.value)
    }))
}

// ISO 3166-1 alpha-2 to alpha-3 country code mapping
let alpha2ToAlpha3: [String: String] = [
    "AF": "AFG", "AX": "ALA", "AL": "ALB", "DZ": "DZA", "AS": "ASM",
    "AD": "AND", "AO": "AGO", "AI": "AIA", "AQ": "ATA", "AG": "ATG",
    "AR": "ARG", "AM": "ARM", "AW": "ABW", "AU": "AUS", "AT": "AUT",
    "AZ": "AZE", "BS": "BHS", "BH": "BHR", "BD": "BGD", "BB": "BRB",
    "BY": "BLR", "BE": "BEL", "BZ": "BLZ", "BJ": "BEN", "BM": "BMU",
    "BT": "BTN", "BO": "BOL", "BQ": "BES", "BA": "BIH", "BW": "BWA",
    "BV": "BVT", "BR": "BRA", "IO": "IOT", "BN": "BRN", "BG": "BGR",
    "BF": "BFA", "BI": "BDI", "CV": "CPV", "KH": "KHM", "CM": "CMR",
    "CA": "CAN", "KY": "CYM", "CF": "CAF", "TD": "TCD", "CL": "CHL",
    "CN": "CHN", "CX": "CXR", "CC": "CCK", "CO": "COL", "KM": "COM",
    "CG": "COG", "CD": "COD", "CK": "COK", "CR": "CRI", "CI": "CIV",
    "HR": "HRV", "CU": "CUB", "CW": "CUW", "CY": "CYP", "CZ": "CZE",
    "DK": "DNK", "DJ": "DJI", "DM": "DMA", "DO": "DOM", "EC": "ECU",
    "EG": "EGY", "SV": "SLV", "GQ": "GNQ", "ER": "ERI", "EE": "EST",
    "SZ": "SWZ", "ET": "ETH", "FK": "FLK", "FO": "FRO", "FJ": "FJI",
    "FI": "FIN", "FR": "FRA", "GF": "GUF", "PF": "PYF", "TF": "ATF",
    "GA": "GAB", "GM": "GMB", "GE": "GEO", "DE": "DEU", "GH": "GHA",
    "GI": "GIB", "GR": "GRC", "GL": "GRL", "GD": "GRD", "GP": "GLP",
    "GU": "GUM", "GT": "GTM", "GG": "GGY", "GN": "GIN", "GW": "GNB",
    "GY": "GUY", "HT": "HTI", "HM": "HMD", "VA": "VAT", "HN": "HND",
    "HK": "HKG", "HU": "HUN", "IS": "ISL", "IN": "IND", "ID": "IDN",
    "IR": "IRN", "IQ": "IRQ", "IE": "IRL", "IM": "IMN", "IL": "ISR",
    "IT": "ITA", "JM": "JAM", "JP": "JPN", "JE": "JEY", "JO": "JOR",
    "KZ": "KAZ", "KE": "KEN", "KI": "KIR", "KP": "PRK", "KR": "KOR",
    "KW": "KWT", "KG": "KGZ", "LA": "LAO", "LV": "LVA", "LB": "LBN",
    "LS": "LSO", "LR": "LBR", "LY": "LBY", "LI": "LIE", "LT": "LTU",
    "LU": "LUX", "MO": "MAC", "MG": "MDG", "MW": "MWI", "MY": "MYS",
    "MV": "MDV", "ML": "MLI", "MT": "MLT", "MH": "MHL", "MQ": "MTQ",
    "MR": "MRT", "MU": "MUS", "YT": "MYT", "MX": "MEX", "FM": "FSM",
    "MD": "MDA", "MC": "MCO", "MN": "MNG", "ME": "MNE", "MS": "MSR",
    "MA": "MAR", "MZ": "MOZ", "MM": "MMR", "NA": "NAM", "NR": "NRU",
    "NP": "NPL", "NL": "NLD", "NC": "NCL", "NZ": "NZL", "NI": "NIC",
    "NE": "NER", "NG": "NGA", "NU": "NIU", "NF": "NFK", "MP": "MNP",
    "NO": "NOR", "OM": "OMN", "PK": "PAK", "PW": "PLW", "PS": "PSE",
    "PA": "PAN", "PG": "PNG", "PY": "PRY", "PE": "PER", "PH": "PHL",
    "PN": "PCN", "PL": "POL", "PT": "PRT", "PR": "PRI", "QA": "QAT",
    "MK": "MKD", "RO": "ROU", "RU": "RUS", "RW": "RWA", "RE": "REU",
    "BL": "BLM", "SH": "SHN", "KN": "KNA", "LC": "LCA", "MF": "MAF",
    "PM": "SPM", "VC": "VCT", "WS": "WSM", "SM": "SMR", "ST": "STP",
    "SA": "SAU", "SN": "SEN", "RS": "SRB", "SC": "SYC", "SL": "SLE",
    "SG": "SGP", "SX": "SXM", "SK": "SVK", "SI": "SVN", "SB": "SLB",
    "SO": "SOM", "ZA": "ZAF", "GS": "SGS", "SS": "SSD", "ES": "ESP",
    "LK": "LKA", "SD": "SDN", "SR": "SUR", "SE": "SWE", "CH": "CHE",
    "SY": "SYR", "TW": "TWN", "TJ": "TJK", "TZ": "TZA", "TH": "THA",
    "TL": "TLS", "TG": "TGO", "TK": "TKL", "TO": "TON", "TT": "TTO",
    "TN": "TUN", "TR": "TUR", "TM": "TKM", "TC": "TCA", "TV": "TUV",
    "UG": "UGA", "UA": "UKR", "AE": "ARE", "GB": "GBR", "US": "USA",
    "UY": "URY", "UZ": "UZB", "VU": "VUT", "VE": "VEN", "VN": "VNM",
    "WF": "WLF", "EH": "ESH", "YE": "YEM", "ZM": "ZMB", "ZW": "ZWE"
]


func threeLetterCountryCode(from twoLetterCode: String) -> String {
    return alpha2ToAlpha3[twoLetterCode] ?? twoLetterCode
}

struct CountryListISO3166: View {
    @Binding var selectedCountryISO: String
    
    var body: some View {
        ForEach(
            NSLocale.isoCountryCodes.sorted {
                // Use localizedString(forRegionCode:) to get the country name
                let countryName1 = Locale.current.localizedString(forRegionCode: $0) ?? ""
                let countryName2 = Locale.current.localizedString(forRegionCode: $1) ?? ""
                return countryName1 < countryName2
            },
            id: \.self,
            content: { countryCode in
                let threeLetterCode = threeLetterCountryCode(from: countryCode)
                
                Button(action: {
                    selectedCountryISO = threeLetterCode
                }, label: {
                    Label(
                        title: {
                            HStack(spacing: 6) {
                                Text("\(countryFlag(countryCode)) \(Locale.current.localizedString(forRegionCode: countryCode) ?? "") - \(threeLetterCode)")
                            }
                        },
                        icon: {
                            Image(systemName: selectedCountryISO == threeLetterCode ? "checkmark" : "")
                                .foregroundColor(Color.blue)
                        }
                    )
                })
            })
    }
}

let countryPhoneCodes: [String: String] = [
    "AF": "93", "AL": "355", "DZ": "213", "US": "1",
    "AD": "376", "AO": "244", "AI": "1", "AG": "1", "AR": "54",
    "AM": "374", "AW": "297", "AU": "61", "AT": "43", "AZ": "994",
    "BS": "1", "BH": "973", "BD": "880", "BB": "1", "BY": "375",
    "BE": "32", "BZ": "501", "BJ": "229", "BM": "1", "BT": "975",
    "BA": "387", "BW": "267", "BR": "55", "IO": "246", "BG": "359",
    "BF": "226", "BI": "257", "KH": "855", "CM": "237", "CA": "1",
    "CV": "238", "KY": "345", "CF": "236", "TD": "235", "CL": "56", "CN": "86",
    "CX": "61", "CO": "57", "KM": "269", "CG": "242", "CK": "682", "CR": "506",
    "HR": "385", "CU": "53", "CY": "537", "CZ": "420", "DK": "45", "DJ": "253",
    "DM": "1", "DO": "1", "EC": "593", "EG": "20", "SV": "503", "GQ": "240",
    "ER": "291", "EE": "372", "ET": "251", "FO": "298", "FJ": "679", "FI": "358",
    "FR": "33", "GF": "594", "PF": "689", "GA": "241", "GM": "220", "GE": "995",
    "DE": "49", "GH": "233", "GI": "350", "GR": "30", "GL": "299", "GD": "1",
    "GP": "590", "GU": "1", "GT": "502", "GN": "224", "GW": "245", "GY": "595", "HT": "509",
    "HN": "504", "HU": "36", "IS": "354", "IN": "91", "ID": "62", "IQ": "964",
    "IE": "353", "IL": "972", "IT": "39", "JM": "1", "JP": "81", "JO": "962",
    "KZ": "77", "KE": "254", "KI": "686", "KW": "965", "KG": "996", "LV": "371",
    "LB": "961", "LS": "266", "LR": "231", "LI": "423", "LT": "370", "LU": "352",
    "MG": "261", "MW": "265", "MY": "60", "MV": "960", "ML": "223",
    "MT": "356", "MH": "692", "MQ": "596", "MR": "222", "MU": "230", "YT": "262",
    "MX": "52", "MC": "377", "MN": "976", "ME": "382", "MS": "1", "MA": "212",
    "MM": "95", "NA": "264", "NR": "674", "NP": "977", "NL": "31", "NC": "687",
    "NZ": "64", "NI": "505", "NE": "227", "NG": "234", "NU": "683",
    "NF": "672", "MP": "1", "NO": "47", "OM": "968", "PK": "92", "PW": "680",
    "PA": "507", "PG": "675", "PY": "595", "PE": "51", "PH": "63", "PL": "48",
    "PT": "351", "PR": "1", "QA": "974", "RO": "40", "RW": "250", "WS": "685",
    "SM": "378", "SA": "966", "SN": "221", "RS": "381", "SC": "248",
    "SL": "232", "SG": "65", "SK": "421", "SI": "386", "SB": "677",
    "ZA": "27", "GS": "500", "ES": "34", "LK": "94", "SD": "249", "SR": "597",
    "SZ": "268", "SE": "46", "CH": "41", "TJ": "992", "TH": "66", "TG": "228",
    "TK": "690", "TO": "676", "TT": "1", "TN": "216", "TR": "90",
    "TM": "993", "TC": "1", "TV": "688", "UG": "256", "UA": "380",
    "AE": "971", "GB": "44", "AS": "1", "UY": "598", "UZ": "998",
    "VU": "678", "WF": "681", "YE": "967", "ZM": "260",
    "ZW": "263"
]

func phoneNumberCode(for countryCode: String) -> String {
    return countryPhoneCodes[countryCode] ?? "Unknown"
}

struct CountryListPhoneCodes: View {
    @Binding var selectedCountryPhoneCode: String
    
    var body: some View {
        ForEach(
            NSLocale.isoCountryCodes.sorted {
                let countryName1 = Locale.current.localizedString(forRegionCode: $0) ?? ""
                let countryName2 = Locale.current.localizedString(forRegionCode: $1) ?? ""
                return countryName1 < countryName2
            },
            id: \.self,
            content: { countryCode in
                let phoneCode = phoneNumberCode(for: countryCode)
                
                Button(action: {
                    selectedCountryPhoneCode = phoneCode
                }, label: {
                    Label(
                        title: {
                            HStack(spacing: 6) {
                                Text("\(countryFlag(countryCode)) \(Locale.current.localizedString(forRegionCode: countryCode) ?? "") - \(phoneCode)")
                            }
                        },
                        icon: {
                            Image(systemName: selectedCountryPhoneCode == phoneCode ? "checkmark" : "")
                                .foregroundColor(Color.blue)
                        }
                    )
                })
            })
    }
}


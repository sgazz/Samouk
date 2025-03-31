# Samouk - Aplikacija za učenje pisanja

Samouk je iOS aplikacija namenjena deci za učenje pisanja slova. Aplikacija kombinuje interaktivno crtanje, prepoznavanje rukopisa i vizuelne efekte za zabavno i efektivno učenje.

## Funkcionalnosti

- Interaktivno crtanje slova
- Prepoznavanje rukopisa
- Vizuelne vodilice za pravilno pisanje
- Animacije ispravnog pisanja slova
- Zvučne efekte za bolje učenje
- Prilagodljive postavke (boja olovke, debljina linije, vidljivost vodilica)

## Zahtevi

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Instalacija

1. Klonirajte repozitorijum:
```bash
git clone https://github.com/sgazz/Samouk.git
```

2. Otvorite `Samouk.xcodeproj` u Xcode-u

3. Izaberite ciljani uređaj ili simulator

4. Pritisnite Run (⌘R) ili Build (⌘B)

## Struktura projekta

```
Samouk/
├── App/
│   ├── SamoukApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Drawing/
│   │   ├── Views/
│   │   │   ├── DrawingCanvas.swift
│   │   │   └── GuideLines.swift
│   │   └── ViewModels/
│   │       └── DrawingViewModel.swift
│   ├── Letter/
│   │   ├── Views/
│   │   │   └── LetterView.swift
│   │   └── ViewModels/
│   │       └── LetterViewModel.swift
│   └── Settings/
│       └── Views/
│           └── SettingsView.swift
├── Core/
│   ├── Models/
│   │   └── LetterModel.swift
│   ├── Services/
│   │   ├── HandwritingRecognitionService.swift
│   │   └── LetterAnimationService.swift
│   └── Utilities/
│       └── AudioManager.swift
└── Resources/
    └── Sounds/
```

## Razvoj

Projekat je organizovan prema MVVM arhitekturi i koristi SwiftUI za korisnički interfejs. Glavne komponente su:

- **DrawingCanvas**: Komponenta za crtanje koja koristi PencilKit
- **GuideLines**: Vizuelne vodilice za pravilno pisanje
- **LetterAnimationService**: Servis za animacije ispravnog pisanja
- **HandwritingRecognitionService**: Servis za prepoznavanje rukopisa

## Licenca

MIT License - pogledajte LICENSE fajl za detalje. 
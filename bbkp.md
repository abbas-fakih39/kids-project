# Kits & Kids — Description du projet

## L'idée

Kits & Kids est une application mobile de **location d'équipements bébé**. Le concept est simple : plutôt d'acheter du matériel coûteux (poussette, siège auto, lit de voyage, etc.) pour un usage ponctuel — vacances, visite chez les grands-parents, déplacement professionnel — les parents le louent à la journée. Le matériel est nettoyé, vérifié et assuré avant chaque location.

La cible principale : les familles en déplacement en France qui ont besoin d'équipements bébé sans vouloir les transporter ou les acheter.

---

## Technologies utilisées

### Mobile — Flutter

| Package                  | Version | Rôle                                    |
| ------------------------ | ------- | --------------------------------------- |
| Flutter (Dart)           | SDK     | Framework UI cross-platform             |
| `provider`               | ^6.1.2  | Etat global (`ChangeNotifier`)          |
| `dio`                    | ^5.4.2  | Client HTTP + intercepteurs JWT         |
| `flutter_secure_storage` | ^9.0.0  | Stockage chiffré des tokens             |
| `shared_preferences`     | ^2.2.2  | Préférences utilisateur persistantes    |
| `google_fonts`           | ^6.2.1  | Police Inter                            |
| `flutter_stripe`         | ^11.0.0 | Paiement Stripe (mode simulé actif)     |
| `cached_network_image`   | —       | Cache des images produits               |

### Backend — NestJS

| Technologie    | Rôle                                          |
| -------------- | --------------------------------------------- |
| NestJS         | Framework Node.js (TypeScript)                |
| Prisma ORM     | Accès base de données + migrations            |
| PostgreSQL     | Base de données relationnelle                 |
| JWT (Passport) | Authentification stateless (access + refresh) |
| bcrypt         | Hashage des mots de passe et refresh tokens   |
| Stripe SDK     | Paiement par carte (mode simulé sans clé)     |
| FCM HTTP API   | Notifications push via fetch() natif          |

---

## Architecture

```
Application Flutter
        │
        ▼
  Provider (ChangeNotifier)   ←── Etat global (AuthProvider)
        │
        ▼
  Repository                  ←── Abstraction des appels réseau
        │
        ▼
  DioClient (Singleton)       ←── HTTP, intercepteurs JWT, refresh silencieux
        │
        ▼
  API NestJS (REST)
        │
        ▼
  Prisma ORM → PostgreSQL
```

### Modules backend

```
auth · users · products · product-images · bookings · cart · payments · reviews
support · admin · notifications
```

### Structure mobile (`lib/`)

```
lib/
├── core/
│   ├── constants/api_constants.dart    ← URLs de base
│   ├── network/dio_client.dart         ← Singleton HTTP + refresh token
│   ├── storage/secure_storage.dart     ← flutter_secure_storage
│   ├── theme/app_theme.dart            ← Design system (couleurs, typo)
│   └── widgets/                        ← app_logo, bottom_nav_bar
└── features/
    ├── splash / onboarding / auth /
    ├── main /                          ← Shell avec bottom nav
    ├── home /                          ← Ecran d'accueil
    ├── search /                        ← Catalogue, filtres, détail produit
    ├── bookings /                      ← Réservations + paiement + confirmation
    ├── cart /                          ← Panier
    ├── admin /                         ← Dashboard, réservations, produits (admin only)
    └── profile /                       ← Profil, édition, FAQ, CGU, contact
```

---

## Modèle de données

```
User ──< Booking ──< BookingProduct >── Product ──< ProductImage
  │          ├──< Payment
  │          └── Review
  └── Cart ──< CartItem >── Product
SupportRequest (standalone)
```

### Enums clés

- **BookingStatus** : `en_attente` · `confirmée` · `en_cours` · `terminée` · `annulée`
- **DeliveryMethod** : `livraison` · `retrait_en_magasin`
- **PaymentStatus** : `en_attente` · `valide` · `echoue` · `rembourse`
- **UserRole** : `user` · `admin`
- **ProductStatus** : `disponible` · `indisponible` · `maintenance`

---

## Fonctionnalités

### Authentification
- Inscription avec nom, prénom, email, mot de passe, date de naissance, téléphone
- Connexion email/mot de passe
- JWT stateless : access token 15 min + refresh token 7 jours
- Refresh silencieux dans le client Dio (queue avec `Completer` pour éviter les race conditions 401)
- Déconnexion (révocation du refresh token côté serveur)
- Tokens stockés dans `flutter_secure_storage`

### Accueil
- Logo et identité de marque (palette navy/bleu)
- Barre de recherche rapide avec filtre
- Grille des catégories : Repas & Alimentation · Poussettes & Chariots · Lits & Sommeil · Sièges Auto · Jouets & Jeux · Packs
- Section "Comment ça marche" en 3 étapes (Choisissez → Réservez → Profitez)
- Compteurs sociaux : 22 000+ avis 5 étoiles · 47 000+ réservations
- Badge de confiance "Propre, Sûr & Assuré"
- Carrousel d'avis clients

### Catalogue & Recherche
- Listing produits paginé (20 par page) avec filtres : catégorie, dates, texte libre
- Filtrage de disponibilité par dates via `groupBy` Prisma (produits à stock épuisé exclus)
- Notes dynamiques : `avg_rating` + `review_count` agrégés depuis les reviews
- Etoiles dynamiques dans les cards (pleines / demi / vides selon `avg_rating`)
- Chips de catégories horizontales en haut
- Filtre dates (SearchFilterScreen) renvoyant les paramètres via `Navigator.pop`
- Détail produit : galerie photos, description, normes de sécurité, prix/jour, reviews, bouton "Réserver"

### Panier
- Ajout/modification/suppression d'articles
- Snapshot du prix au moment de l'ajout (`cart_item_price_snapshot`)
- Recalcul automatique du total à la modification quantité/dates

### Réservations
- Création en transaction Prisma : vérification + décrémentation du stock atomique
- Calcul du total : `prix_jour × quantité × nb_jours`
- Options de livraison : livraison à domicile (avec champs adresse rue/ville/CP) ou retrait en agence
- Méthode de paiement : carte bancaire · Apple Pay · virement
- Annulation possible si statut `en_attente` ou `confirmée` (stock restitué en transaction)
- Génération de facture (`INV-XXXXXX`) avec détail des lignes, adresse, méthode de paiement
- Ecran détail réservation : statut, produits, livraison, paiement, bouton d'annulation

### Paiement
- Intégration Stripe avec `flutter_stripe ^11.0.0`
- **Mode simulé** (sans clé Stripe) : banner orange "Mode test activé", formulaire carte masqué, `confirmPayment` Stripe ignorée
- **Mode réel** (avec `STRIPE_SECRET_KEY`) : `CardFormField`, `confirmPayment`, webhook Stripe signé (`stripe-signature`)
- Webhook HMAC-SHA256 vérifié sur le raw body
  - `payment.succeeded` → paiement `valide` + réservation `confirmée`
  - `payment.failed` → paiement `échoué`
  - `payment.refunded` → paiement `remboursé` + réservation `annulée` + stock restitué

### Avis
- Dépôt d'un avis lié à une réservation terminée
- Affichage des avis sur la fiche produit (nom, note, commentaire)

### Support
- `POST /support` stocke les demandes en base (`support_requests`)
- 3 tests unitaires

### Notifications push (FCM)
- Token FCM stocké via `POST /users/me/push-token`
- Envoi automatique à chaque changement de statut de réservation
- Messages : confirmée · en cours · terminée · annulée
- Implémentation sans `firebase-admin` : `fetch()` natif vers API FCM legacy
- Silencieux quand `FCM_SERVER_KEY` absent (pas d'erreur levée)

### Préférences notifications
- `GET /users/me/preferences` renvoie `push`, `promo`, `transactional`
- `PATCH /users/me/preferences` met à jour uniquement les champs fournis
- Flutter `notifications_screen.dart` : chargement au démarrage + toggle en temps réel

### Profil utilisateur
- Modification des informations personnelles
- Changement de mot de passe
- Notifications (préférences persistées via API)
- FAQ, contact support, CGU, politique de confidentialité, charte hygiène
- Déconnexion
- Lien vers l'espace admin visible uniquement pour les utilisateurs `admin`

### Espace admin (rôle admin uniquement)
- **Dashboard** : 6 stats en grille (réservations totales, en attente, en cours, confirmées, utilisateurs, chiffre d'affaires)
- **Gestion réservations** : liste paginée avec chargement infini, changement de statut via bottom sheet (transitions valides uniquement)
- **Gestion produits** : liste complète, édition du stock via dialog, changement de statut (disponible / indisponible / maintenance)

---

## Design System

| Token         | Hex       | Usage                       |
| ------------- | --------- | --------------------------- |
| `navy`        | `#1B3A57` | Titres, navbar, fond        |
| `bluePrimary` | `#3C82F5` | Boutons, accents, liens     |
| `lightBlue`   | `#DDE9FE` | Chips, surfaces secondaires |
| `offWhite`    | `#F4F7FA` | Fond des écrans             |
| `textDark`    | `#334155` | Corps de texte              |
| `textGrey`    | `#9CA3AF` | Placeholders, labels        |
| `success`     | `#22C55E` | Etats de confirmation       |
| `error`       | `#EF4444` | Messages d'erreur           |

- **Police** : Inter (Google Fonts)
- **Boutons** : hauteur min 54 px, `border-radius: 14px`, pleine largeur
- **Champs** : fond blanc, `border-radius: 14px`, bordure `#E2E8F0`
- **Bottom nav** : fond navy `#1B3A57`, indicateur pill sur l'onglet actif

---

## Tests

### Backend — 31 tests (8 suites)

| Suite                             | Tests |
| --------------------------------- | ----- |
| `auth.service.spec.ts`            | 4     |
| `users.service.spec.ts`           | 5     |
| `products.service.spec.ts`        | 8     |
| `payments.service.spec.ts`        | 3     |
| `admin.service.spec.ts`           | 3     |
| `support.service.spec.ts`         | 3     |
| `notifications.service.spec.ts`   | 2     |
| `bookings.service.spec.ts`        | 3     |

### Flutter — 15 tests (widget tests)

- App boot, LoginScreen x4, RegisterScreen x2, ProfileScreen x4
- BookingsScreen x1, SearchScreen x1, BookingOptionsScreen x2
- `flutter analyze` : 25 infos pré-existants, 0 erreur

---

## Migrations Prisma

| Migration                          | Contenu                                                                        |
| ---------------------------------- | ------------------------------------------------------------------------------ |
| `add_support_requests_and_indexes` | Table `support_requests` + indexes `products` / `bookings`                     |
| `add_stripe_intent_id`             | Colonne `payments_stripe_intent_id` sur `payments`                             |
| `add_notif_prefs_to_user`          | 3 booléens : `user_notif_push`, `user_notif_promo`, `user_notif_transactional` |
| `add_user_push_token`              | Colonne `user_push_token` sur `User`                                           |

---

## Sécurité

- Mots de passe hashés bcrypt (salt 12)
- Refresh tokens hashés bcrypt en base (jamais stockés en clair)
- Vérification HMAC-SHA256 timing-safe sur les webhooks
- Injection SQL impossible (Prisma paramétrise toutes les requêtes)
- CORS configuré via variable d'environnement `ALLOWED_ORIGINS`
- Guards JWT sur toutes les routes privées ; guard `Roles` pour les routes admin
- HTML strippé à l'entrée (transform `StripHtml`)

---

## Démarrage

```bash
# Mobile
cd mobile_app
flutter pub get
flutter run

# Backend
cd backend
npm install
# Variables requises :
#   DATABASE_URL, JWT_ACCESS_SECRET, JWT_REFRESH_SECRET, WEBHOOK_SECRET, ALLOWED_ORIGINS
# Variables optionnelles (paiement réel Stripe) :
#   STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
# Variables optionnelles (notifications push FCM) :
#   FCM_SERVER_KEY
npx prisma migrate deploy
npm run start:dev
```

---

## Backlog

- **Stripe réel** : ajouter `STRIPE_SECRET_KEY` + `STRIPE_WEBHOOK_SECRET` dans `.env`, `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...` au `flutter run`
- **Notifications push réelles** : ajouter `FCM_SERVER_KEY`, intégrer `firebase_messaging` côté Flutter
- Espace admin — gestion utilisateurs (liste, désactivation)
- Tests widget supplémentaires (cart, payment flow, admin screens)

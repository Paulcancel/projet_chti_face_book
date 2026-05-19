import 'package:flutter/material.dart';

import '../modeles/donnees.dart';
import '../services_firebase/service_authentification.dart';

class PageAuthentification extends StatefulWidget {
  const PageAuthentification({
    super.key,
    required this.authentificationService,
  });

  final ServiceAuthentification authentificationService;

  @override
  State<PageAuthentification> createState() => _PageAuthentificationState();
}

class _PageAuthentificationState extends State<PageAuthentification> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();

  bool _creationCompte = false;
  bool _chargement = false;
  String? _erreur;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    _prenomController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    final erreur =
        _creationCompte
            ? await widget.authentificationService.creerCompte(
              email: _emailController.text,
              motDePasse: _motDePasseController.text,
              prenom: _prenomController.text,
              nom: _nomController.text,
            )
            : await widget.authentificationService.connecter(
              email: _emailController.text,
              motDePasse: _motDePasseController.text,
            );

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;
      _erreur = erreur;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.groups_2_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Jargon.app,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              _creationCompte
                                  ? Jargon.creerCompte
                                  : Jargon.connexion,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_creationCompte) ...<Widget>[
                              TextFormField(
                                controller: _prenomController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Prénom',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nomController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Nom',
                                  prefixIcon: Icon(Icons.badge),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                hintText: 'paul@chtibouc.fr',
                                prefixIcon: Icon(Icons.alternate_email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final texte = value?.trim() ?? '';
                                if (!texte.contains('@')) {
                                  return 'Adresse e-mail invalide.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _motDePasseController,
                              obscureText: true,
                              onFieldSubmitted: (_) => _soumettre(),
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'azerty',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Mot de passe requis.';
                                }
                                return null;
                              },
                            ),
                            if (_erreur != null) ...<Widget>[
                              const SizedBox(height: 12),
                              Text(
                                _erreur!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: _chargement ? null : _soumettre,
                              icon:
                                  _chargement
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Icon(
                                        _creationCompte
                                            ? Icons.person_add_alt_1
                                            : Icons.login,
                                      ),
                              label: Text(
                                _creationCompte
                                    ? Jargon.creerCompte
                                    : Jargon.seConnecter,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed:
                                  _chargement
                                      ? null
                                      : () {
                                        setState(() {
                                          _creationCompte = !_creationCompte;
                                          _erreur = null;
                                        });
                                      },
                              child: Text(
                                _creationCompte
                                    ? Jargon.dejaUnCompte
                                    : Jargon.nouveauCompte,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        icon: Icon(Icons.login),
                        label: Text(Jargon.connexion),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        icon: Icon(Icons.person_add_alt_1),
                        label: Text(Jargon.inscription),
                      ),
                    ],
                    selected: <bool>{_creationCompte},
                    onSelectionChanged:
                        _chargement
                            ? null
                            : (selection) {
                              setState(() {
                                _creationCompte = selection.first;
                                _erreur = null;
                              });
                            },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

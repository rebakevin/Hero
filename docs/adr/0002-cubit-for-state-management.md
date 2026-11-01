# ADR 0002 — Cubit (`flutter_bloc`) for state management

Nov 1, 2026 · Status: accepted

## Context

The assignment asks for a modern state management approach. The app has many live screens
(feed, details, history, votes, notifications) and several forms, and the rubric asks for explicit
loading, loaded, empty and error states.

## Decision

Use `flutter_bloc` with **Cubit** (not full Bloc events), one Cubit per screen or feature scope,
with a repository layer between Cubits and the backends.

- States are sealed classes with `Equatable`, so the compiler forces every case to be handled.
  Forms use one state class with a status enum.
- A Cubit subscribes to a repository stream once and cancels it in `close()`.
- Cubits never use `BuildContext`; screens react with `BlocListener`.
- Cubits do not call each other; they share data through repositories.

## Consequences

- Loading, empty and error states are part of the type, which maps directly to the rubric.
- Cubits are tested with `bloc_test` and hand-written repository fakes, with no widgets needed.
- More small classes than a single global store, in exchange for narrow scope and automatic
  disposal when a route closes.
- Plain `Navigator.push` plus an auth gate is enough for two roles, so no router package is added.

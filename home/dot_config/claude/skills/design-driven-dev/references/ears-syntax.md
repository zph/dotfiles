# EARS Syntax Reference

EARS (Easy Approach to Requirements Syntax) provides structured patterns for writing unambiguous, testable requirements.

**Source**: https://alistairmavin.com/ears/

---

## Spec File Format

Specs live in `/docs/specs/` files with status markers. Each requirement is one line:

```markdown
- [x] **{ID}**: {Requirement statement}
- [ ] **{ID}**: {Requirement statement}
- [D] **{ID}**: {Requirement statement}
```

### Status Markers

- `[x]` — **Implemented**: Code and tests exist that realize this spec
- `[ ]` — **Active gap**: Should be implemented, work to do
- `[D]` — **Deferred**: Correct intent, not needed yet (e.g., scaling optimization not needed at current user count)

### Removing Specs

**Delete specs that are no longer wanted.** Do not mark them — just remove the line. Git preserves history if the rationale needs to be recovered later. A spec's presence means the intent is current; absence means the intent was withdrawn.

### Example

```markdown
## User Authentication

- [x] **AUTH-UI-001**: The system shall display a login button on the home screen.
- [x] **AUTH-UI-002**: When the user taps the login button, the system shall navigate to the authentication flow.
- [ ] **AUTH-API-001**: The system shall validate JWT tokens on every authenticated API request.
- [D] **AUTH-API-002**: Where multi-factor authentication is enabled, the system shall require a second factor.
```

---

## Semantic ID Format

`{FEATURE}-{TYPE}-{NNN}`

- **FEATURE**: 2-4 letter prefix for the feature area (e.g., `AUTH`, `CART`, `DASH`)
- **TYPE**: Component type (`UI`, `API`, `DATA`, `NAV`, `BE`, `PROC`)
- **NNN**: Sequential number, zero-padded

Keep IDs stable - don't renumber when inserting requirements.

---

## EARS Requirement Patterns

### 1. Ubiquitous (always true)

**Pattern**: "The system shall..."

```
- **CART-UI-001**: The system shall display the item count in the cart icon.
```

### 2. Event-Driven (triggered by action)

**Pattern**: "When [trigger], the system shall..."

```
- **CART-UI-002**: When the user taps "Add to Cart", the system shall add the item and show a confirmation.
```

### 3. State-Driven (while condition is true)

**Pattern**: "While [state], the system shall..."

```
- **CART-UI-003**: While the cart is empty, the system shall display an empty state message.
```

### 4. Optional (feature-dependent)

**Pattern**: "Where [feature enabled], the system shall..."

```
- **AUTH-OPT-001**: Where biometric auth is enabled, the system shall prompt for Face ID before checkout.
```

### 5. Unwanted (error handling)

**Pattern**: "If [unwanted condition], then the system shall..."

```
- **CART-UI-004**: If the network request fails, then the system shall display cached data with an error banner.
```

---

## Code Annotations

Reference specs in implementation:

```typescript
// @spec CART-UI-001, CART-UI-002
export function CartIcon({ ... }) {
  // Implementation
}
```

In tests:

```typescript
// @spec CART-UI-002
it('adds item to cart on tap', () => {
  // Test implementation
});
```

---

## Traceability

In implementation plans, map specs to phases:

```markdown
## Phase 1: Core Cart UI
Specs: CART-UI-001 through CART-UI-010
```

# Feature modules

Feature modules group screens and widgets around user tasks. Presentation code should render the interface and collect user input, then delegate application workflows to providers.

| Feature folder | Responsibility |
| --- | --- |
| `authentication/` | Registration, sign-in, email verification, and authentication fields |
| `home/` | Student dashboard and report summary |
| `incidents/` | Create/edit forms, list, search, filters, and details |
| `profile/` | User profile and settings entry |
| `settings/` | Theme and local settings UI |
| `splash/` | Initial loading while session/profile state resolves |
| `staff/` | Staff incident queue, review, and status controls |

## Guidelines

- Reuse components from `lib/shared/` where appropriate.
- Do not call Firestore, Storage, or Firebase Auth directly from a feature screen.
- Dispose controllers and widget-owned subscriptions.
- Keep student actions consistent with Firestore ownership restrictions.
- Treat staff route checks as navigation behavior; Firebase rules remain the authorization boundary.

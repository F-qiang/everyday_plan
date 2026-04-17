#include "oneDriveAppConfig.h"

namespace OneDriveAppConfig {

QString defaultClientId()
{
    // TODO: Replace with the official Microsoft Application (client) ID
    // registered by the app author before release.
    return QString();
}

bool hasBuiltInClientId()
{
    return !defaultClientId().trimmed().isEmpty();
}

} // namespace OneDriveAppConfig

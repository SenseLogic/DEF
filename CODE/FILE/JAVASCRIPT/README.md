![](https://github.com/senselogic/DEF/blob/master/LOGO/def.png)

# DEF

Data Exchange Format file processing.

## Features

*   Can load DEF files from disk.
*   Can execute custom commands to :
    *   Load a DEF file  : '@file.def'
    *   Load several DEF files : '@folder/*.def'

```
{
    settings
        {
            theme
                dark
            fontSize
                16
            features
                [
                    search
                    filter
                    sort
                ]
            version
                2.0¨
            metrics
                {
                    cpuUsage
                        0.75
                    memoryUsage
                        0.6
                    networkTraffic
                        1234567890
                }
            logging
                true
        }
    plugins
        [
            {
                name
                    Analytics
                status
                    enabled
            }
            {
                name
                    SEO
                status
                    disabled
            }
        ]
    users
        [
            [
                name
                role
            ]
            [
                John Doe
                administrator
            ]
            [
                Jane Smith
                publisher
            ]
        ]{}
    texts
        {
            home
                "Home
                ¨fr:Accueil
                ¨de:Startseite
                ¨ja:ホーム"
            services
                `Services
                ¨fr:Services
                ¨de:Dienstleistungen
                ¨ja:サービス`
            contact
                ´Contact
                ¨fr:Contact
                ¨de:Kontakt
                ¨ja:連絡先´
        }
    articles
        '@articles/*.def'
}
```

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU Lesser General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.

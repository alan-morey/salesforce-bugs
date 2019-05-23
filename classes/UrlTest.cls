@IsTest
public class UrlTest {
    /**
     * Under a normal test execution context Url.getOrgDomainUrl() 
     * returns a url that starts with https://
     *
     * However, when tests are executed during a metadata Deployment
     * then Url.getOrgDomainUrl() returns a http:// url instead.
     *
     * This is unexpected and insconsistent behavior
     */
    @IsTest
    static void urlGetOrgDomainUrl_shouldReturnHttpsUrl() {
        final String expectedScheme = 'https://';
        final String url = Url.getOrgDomainUrl().toExternalForm();

        System.assert(
            url.startsWith(expectedScheme),
            String.format(
                'Expected OrgDomainUrl <{0}> to start with {1}',
                new String[] { url, expectedScheme }));
    }
}

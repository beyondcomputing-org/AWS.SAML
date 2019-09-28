Import-Module '.\AWS.SAML.Utils.psm1' -Force

Describe 'Push-StringArrayValue' {
    $array = @(
        'f1d23cff-03de-4931-b2fc-06791e5f2df0',
        '76adee34-b0b1-47ce-86ca-dbfd679f8fc7',
        'aab9983f-9a45-4d6a-a7c8-bac20a3b4c33'
    )
    $value = 'Replaced'

    Context 'Value Exists' {
        $response = Push-StringArrayValue -Array $array -Match 'f1d23cff' -Value $value

        It "Returns same size array" {
            $response.Count | Should Be $array.Count
        }

        It "Updates the correct value" {
            $response[0] | Should Be $value
        }

        It "Doesn't modify other values" {
            $response[1] | Should Be $array[1]
            $response[2] | Should Be $array[2]
        }
    }

    Context "Value Doesn't Exist" {
        $response = Push-StringArrayValue -Array $array -Match '123456' -Value $value

        It "Returns array with 1 new item" {
            $response.Count | Should Be ($array.Count + 1)
        }

        It "Updates the correct value" {
            $response[-1] | Should Be $value
        }

        It "Doesn't modify other values" {
            $response[0] | Should Be $array[0]
            $response[1] | Should Be $array[1]
            $response[2] | Should Be $array[2]
        }
    }
}
/**
 * Copyright 2020 Appvia Ltd <info@appvia.io>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"context"
	"fmt"

	azdns "github.com/Azure/azure-sdk-for-go/services/dns/mgmt/2018-05-01/dns"
	"github.com/Azure/go-autorest/autorest/azure/auth"
	"github.com/Azure/go-autorest/autorest/to"
)

func main() {
	fmt.Println("HELLO VICAR!")

	sub1 := "18e41964-4477-47e4-b5c0-bfef3724b4b8"
	sub2 := "0fe8ae6c-8466-4a1e-8a65-80403a6c1b9f"
	// identityRes1 := "/subscriptions/18e41964-4477-47e4-b5c0-bfef3724b4b8/resourcegroups/kore-msidentityhack-aks-dev-infra-uksouth/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id1"
	// identityRes2 := "/subscriptions/18e41964-4477-47e4-b5c0-bfef3724b4b8/resourcegroups/kore-msidentityhack-aks-dev-infra-uksouth/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id2"
	clientID1 := "ea1ebef7-45bc-4811-98ea-94ddf544c0ef"
	clientID2 := "c8312420-5461-4089-b66b-9c481382724d"

	fmt.Println()
	fmt.Println("------------------------ SUBSCRIPTION 1 ------------------------")
	fmt.Println()
	fmt.Println("ID 1 on Sub 1")
	fmt.Println()
	err := doThingWithPrivs1(sub1, clientID1)
	if err != nil {
		fmt.Println(fmt.Errorf("ID1 ON SUBCRIPTION 1 DIDN'T WORK, THE VICAR IS SAD: %w", err))
	} else {
		fmt.Println("ID1 on Subscription 1 worked, the vicar Jumps for Joy")
	}

	fmt.Println()
	fmt.Println("ID 2 on Sub 1")
	fmt.Println()
	err = doThingWithPrivs1(sub1, clientID2)
	if err != nil {
		fmt.Println(fmt.Errorf("ID2 ON SUBCRIPTION 1 DIDN'T WORK, THE VICAR IS SAD: %w", err))
	} else {
		fmt.Println("ID2 on Subscription 1 worked, the vicar Jumps for Joy")
	}

	fmt.Println()
	fmt.Println("------------------------ SUBSCRIPTION 2 ------------------------")
	fmt.Println()
	fmt.Println("ID 1 on Sub 2")
	fmt.Println()
	err = doThingWithPrivs1(sub2, clientID1)
	if err != nil {
		fmt.Println(fmt.Errorf("ID1 ON SUBCRIPTION 2 DIDN'T WORK, THE VICAR IS SAD: %w", err))
	} else {
		fmt.Println("ID1 on Subscription 1 worked, the vicar Jumps for Joy")
	}

	fmt.Println()
	fmt.Println("ID 2 on Sub 2")
	fmt.Println()
	err = doThingWithPrivs1(sub2, clientID2)
	if err != nil {
		fmt.Println(fmt.Errorf("ID2 ON SUBCRIPTION 2 DIDN'T WORK, THE VICAR IS SAD: %w", err))
	} else {
		fmt.Println("ID2 on Subscription 1 worked, the vicar Jumps for Joy")
	}

}

func doThingWithPrivs1(subID, clientID string) error {
	// conf := auth.NewMSIConfig()
	// conf.ClientID = clientID
	a, err := auth.NewAuthorizerFromEnvironment()
	if err != nil {
		return err
	}

	client := azdns.NewZonesClient(subID)
	client.Authorizer = a

	fmt.Println("Attempting to list existing zones in subscription", subID)
	ctx := context.Background()
	for zonesPage, err := client.List(ctx, to.Int32Ptr(100)); zonesPage.NotDone(); err = zonesPage.NextWithContext(ctx) {
		if err != nil {
			return err
		}
		for _, zone := range zonesPage.Values() {
			fmt.Println(*zone.Name)
		}
	}

	fmt.Println("Attempting to creating zone in subscription", subID)
	res, err := client.CreateOrUpdate(ctx, "kore-msidentityhack-aks-dev-infra-uksouth", "horse.appvia.io", azdns.Zone{}, "", "")
	if err != nil {
		return err
	}
	fmt.Println("Created ", res.Name)
	return nil
}

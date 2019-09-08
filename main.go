package main

import (
	"log"

	"github.com/hashicorp/vault/api"
)

// GitCommit just a commit hash that will be injected during image compiling
var GitCommit string

func main() {
	secretAddr := ""
	secretToken := ""
	_, _ = secretAddr, secretToken

	log.Printf("switchable container version: %s", GitCommit)
	client, clientErr := api.NewClient(&api.Config{
		Address: "http://127.0.0.1:8200",
	})

	if clientErr != nil {
		log.Println("error gaes", clientErr)
	}
	log.Println("created vault client")
	client.SetToken("s.jHtIrZHNR7PnGCK1TRDBGMUB")
	secret, readErr := client.Logical().Read("kv/service/payment")
	_, _ = secret, readErr
	if readErr != nil {
		log.Println("error while reading configuration values", readErr)
	}
	log.Printf("secret: %+v", secret.Data)

	type config struct {
		Env     string `yaml:"env"`
		AppName string `yamml:"app_name"`
	}
	conf := config{}
	loadConfig(conf)
}

func loadConfig(conf interface{}) {

}

import gql from 'graphql-tag'
import { apolloClient } from '@/vue-apollo'

export async function login(formlogin) {
  const { data } = await apolloClient.mutate({
    mutation: gql`mutation login($email: String!, $password: String!) {
      login(input: { email: $email, password: $password }) {
        jwt
      }
    }
    `,
    variables: {
      email: formlogin.username,
      password: formlogin.password
    },
    error(error) {
      this.error = JSON.stringify(error.message)
    }
  })
  return data
}

export async function getInfo(token) {
  const { data } = await apolloClient.mutate({
    mutation: gql`query userInfo {
      currentRole {
        nodes {
          name
        }
      }
      currentUser {
        firstName
      }
    }`
  })
  return data
}

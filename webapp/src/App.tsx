import { HStack, VStack } from '@chakra-ui/react';
import { useQuery } from '@tanstack/react-query';

export function App() {
  const { isPending, error, data } = useQuery({
    queryKey: ['repoData'],
    queryFn: () =>
      fetch('https://api.github.com/repos/rthomare/bounce').then((res) =>
        res.json()
      ),
  });
  if (isPending) return 'Loading...';
  if (error) return 'An error has occurred: ' + error.message;
  return (
    <VStack>
      <h1>{data.name}</h1>
      <p>{data.description}</p>
      <HStack>
        <strong>👀 {data.subscribers_count}</strong>{' '}
        <strong>✨ {data.stargazers_count}</strong>{' '}
        <strong>🍴 {data.forks_count}</strong>
      </HStack>
    </VStack>
  );
}
